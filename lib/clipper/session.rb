module Clipper

  class Session
    
    class UnitOfWork

      def initialize(session, flush_immediately = false)
        @session = session
        @flush_immediately = flush_immediately
        @work_orders = []
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
          if association.is_a?(Clipper::Mappings::BelongsTo)
            if (associated_object = association.get(object))
              @session.enlist(associated_object)
            end
          end
        end

        @work_orders << new_work_order

        @session.mappings[object.class].associations.each do |association|
          if association.is_a?(Clipper::Mappings::HasMany)
            association.get(object).each do |associated_object|
              @session.enlist(associated_object)
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

      def execute
        while (work_order = @work_orders.shift)
          case work_order[0]
          when :create, :update then
            collection = work_order[1].is_a?(Collection) ? work_order[1] : Collection.new(@session.mappings[work_order[1].class], [work_order[1]].flatten)

            @session.mappings[work_order[1].class].associations.each do |association|
              next unless association.is_a?(Clipper::Mappings::BelongsTo)

              collection.each do |instance|
                if (associated_object = association.get(instance))
                  association.set_key(instance, associated_object)
                end
              end
            end

            @session.repository.send(work_order[0], collection, @session)

            @session.mappings[work_order[1].class].associations.each do |association|
              next unless association.is_a?(Clipper::Mappings::HasMany)

              # Since we just created the instance, we need to ensure that all associated items know about
              # the new parent key
              collection.each do |instance|
                association.get(instance).each do |associated_instance|
                  association.set_key(instance, associated_instance)
                end
              end
            end
          # when :update then
          #   collection = work_order[1].is_a?(Collection) ? work_order[1] : Collection.new(@session.mappings[work_order[1].class], [work_order[1]].flatten)
          #   @session.repository.update(collection, @session)
          # 
          #   @session.mappings[work_order[1].class].associations.each do |association|
          #     next unless association.is_a?(Clipper::Mappings::HasMany)
          # 
          #     # Since we just created the instance, we need to ensure that all of associated items know about
          #     # its parent's key
          #     collection.each do |instance|
          #       association.get(instance).each do |associated_instance|
          #         association.set_key(instance, associated_instance)
          #       end
          #     end
          #   end
          when :delete then
            collection = work_order[1].is_a?(Collection) ? work_order[1] : Collection.new(@session.mappings[work_order[1].class], [work_order[1]].flatten)
            @session.repository.delete(collection, @session)
          end
        end
      end

    end

    class RepositoryMissingError < StandardError
      def initialize(repository_name)
        super("Repository #{repository_name.inspect} not a registered repository, can't initiate a Session")
      end
    end

    def initialize(repository_name, immediate_flush = false)
      raise ArgumentError.new("Session repository_name must be a String") unless repository_name.is_a?(String)
      raise ArgumentError.new("Session repository_name must not be blank") if repository_name.blank?

      @repository_name = repository_name
      @identity_map = IdentityMap.new
      @immediate_flush = immediate_flush
      @unit_of_work = UnitOfWork.new(self, immediate_flush)
    end

    def repository
      @repository ||= begin
        if repository = Clipper::registrations[@repository_name]
          repository
        else
          raise RepositoryMissingError.new(@repository_name)
        end
      end
    end

    def identity_map
      @identity_map
    end

    def enlist(object)
      @unit_of_work.register(object)

      self
    end
    alias << enlist
    alias save enlist

    def delete(object)
      @unit_of_work.register_deletion(object)
      
      self
    end
    alias - delete

    def flush
      @unit_of_work.execute
    end

    def mappings
      repository.mappings
    end

    def map(target, mapped_name, &b)
      Clipper::Mappings[@repository_name].map(target, mapped_name, &b)
    end

    def get(target, *keys)
      mapping = repository.mappings[target]

      conditions = Query::AndExpression.new(*mapping.keys.zip(keys).map { |condition| Query::Condition.eq(*condition) })

      query = Query.new(mapping, nil, conditions)

      map_results([repository.select(query, self).first]).first
    end

    def all(target)
      mapping = repository.mappings[target]
      criteria = Clipper::Query::Criteria.new(mapping)

      yield(criteria) if block_given?

      map_results(repository.select(Query.new(mapping, criteria.__options__, criteria.__conditions__), self))
    end

    def find(target, options, conditions)
      mapping = target.is_a?(Clipper::Mappings::Mapping) ? target : repository.mappings[target]

      map_results(repository.select(Query.new(mapping, options, conditions), self))
    end

    def key(instance)
      mapping = repository.mappings[instance.class]
      mapping.keys.map do |field|
        field.get(instance)
      end
    end

    # def save(instance)
    #   self << instance
    # 
    #   @unit_of_work.flush if @flush_immediately
    # end

    # def save_cascade(collection, visited = [])
    #   return if visited.include?(collection)
    # 
    #   collection = collection.is_a?(Collection) ? collection : Collection.new(mappings[collection.class], [collection].flatten)
    # 
    #   repository.save(collection, self)
    # 
    #   visited << collection
    #   collection.each do |item|
    #     visited << self.key(item)
    #   end
    # 
    #   collection.mapping.associations.each do |association|
    #     case association
    #     when Mappings::BelongsTo then
    #       collection.each do |item|
    #         data = association.get(item)
    #         return if data.nil?
    #         return if visited.include?(self.key(data))
    # 
    #         if data
    #           save_cascade(data, visited)
    #           association.set_key(item, data)
    # 
    #           # This should really only be called if the item was new to begin with
    #           save(item)
    #         end
    #       end
    #     when Mappings::HasMany then
    #       collection.each do |item|
    #         data = association.get(item)
    #         next if visited.include?(data)
    # 
    #         data.each do |associated_item|
    #           association.set_key(item, associated_item)
    #         end
    # 
    #         save_cascade(data, visited)
    #       end
    #     end
    #   end
    # 
    #   collection
    # end

    # def delete(collection)
    #   collection = Collection.new(mappings[collection.class], [collection].flatten) unless collection.is_a?(Collection)
    #   
    #   result = repository.delete(collection, self)
    #   result
    # end

    def validate(object, context_name = 'default')
      Clipper::validate(object, context_name)
    end

    def load(object, field)
    end

    def stored?(instance)
      instance.__session__ &&
        instance.__session__.repository == repository &&
        instance.__session__.identity_map.include?(instance)
    end

    private

    def map_results(results)
      results.each do |result|
        result.instance_variable_set("@__session__", self)
        self.identity_map.add(result)
      end

      results
    end

  end # class Session
end # module Clipper