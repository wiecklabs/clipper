module Clipper
  class UnitOfWork

    def initialize(session, flush_immediately = false)
      @session = session
      @flush_immediately = flush_immediately
      @work_orders = []
      @original_values = {}
    end

    def register(object)
      # TODO: ensure that this only happens for a single repository
      if object.__session__ && object.__session__.identity_map.include?(object)
        @session.identity_map.add(object)
      end

      object.instance_variable_set("@__session__", @session)

      new_work_order = [@session.stored?(object) ? :update : :create, object]

      if @work_orders.any? { |wo| wo[0] == new_work_order[0] && wo[1] == new_work_order[1] }
        return
      end

      @session.mappings[object.class].associations.each do |association|
        if association.is_a?(Clipper::Mappings::ManyToOne)
          if (associated_object = association.get(object))
            @session.enlist(associated_object)
          end
        end
      end

      # Add CREATE ZooKeeper
      @work_orders << new_work_order

      @session.mappings[object.class].associations.each do |association|
        if association.is_a?(Clipper::Mappings::OneToMany)
          association.get(object).each do |associated_object|
            @session.enlist(associated_object)
          end
        end
      end

      @session.mappings[object.class].associations.each do |association|
        if association.is_a?(Clipper::Mappings::ManyToMany)

          association.get(object).each do |associated_object, link|
            @session.enlist(associated_object)
            @session.enlist(link)
          end
        end
      end

      execute if @flush_immediately
    end

    def register_deletion(object)
      if object.__session__ && object.__session__.identity_map.include?(object)
        @session.identity_map.add(object)
      end

      object.instance_variable_set("@__session__", @session)

      if @session.stored?(object)
        @work_orders << [:delete, object]
      else
        @work_orders << [:remove, object]
      end

      execute if @flush_immediately
    end

    def register_clean(object)
      original = {}
      @session.mappings[object.class].fields.each do |field|
        original[field] = field.accessor.get(object)
      end
      @original_values[object.object_id] = original
      nil
    end

    def proxy_for(object)
      Clipper::Model::Proxy.new(object, @session.mappings[object.class], @original_values[object.object_id])
    end

    def execute
      while (work_order = @work_orders.shift)
        case work_order[0]
        when :create, :update then
          collection = work_order[1].is_a?(Collection) ? work_order[1] : Collection.new(@session.mappings[work_order[1].class], [work_order[1]].flatten)

          @session.mappings[work_order[1].class].associations.each do |association|
            next unless association.is_a?(Clipper::Mappings::ManyToOne)

            collection.each do |instance|
              if (associated_object = association.get(instance))
                association.set_key(instance, associated_object)
              end
            end
          end

          @session.repository.send(work_order[0], collection, @session)

          @session.mappings[work_order[1].class].associations.each do |association|
            next unless association.is_a?(Clipper::Mappings::OneToMany)

            # Since we just created the instance, we need to ensure that all associated items know about
            # the new parent key
            collection.each do |instance|
              association.get(instance).each do |associated_instance|
                association.set_key(instance, associated_instance)
              end
            end
          end

        when :delete then
          collection = work_order[1].is_a?(Collection) ? work_order[1] : Collection.new(@session.mappings[work_order[1].class], [work_order[1]].flatten)
          @session.repository.delete(collection, @session)
        end
      end
    end

  end
end