module Clipper
  class Mappings

    class ManyToManyCollection < ::Clipper::Collection

      def initialize(association, parent, children, links)
        @association = association
        @parent = parent
        @collection = children
        @links = links
        @mapping = association.associated_mapping
      end

      def add(item, link)
        @collection << item
        @links << link

        @parent.__session__.enlist(item) if @parent.__session__
        @parent.__session__.enlist(link) if @parent.__session__

        @association.set_key(@parent, item, link)

        item
      end
      alias << add

      def each
        @collection.zip(@links).each do |item, link|
          yield item, link
        end
      end

    end

    class ManyToMany < Association

      def initialize(mapping, name, mapped_name, target_mapping_name)
        @mapping = mapping
        @name = name
        @mapped_name = mapped_name
        @target_mapping_name = target_mapping_name

        @target = Class.new do
          include Clipper::Model

          attr_accessor :parent, :child

          def initialize(parent, child)
            @parent, @child = parent, child
          end
        end

        begin
          setup_join_map
        rescue Clipper::Mappings::UnmappedClassError
          # setup_join_map failed because the mapping referenced by "mapped_name" doesn't exist yet
          # this callback registartion lets just recieve a notification when the map is added
          # so we can finish creating our join map
          @mapping.mappings.register_map_callback(mapped_name) do |mapping|
            setup_join_map
          end
        end
      end

      def key_field_name(field)
        "#{field.mapping.name}_#{field.name}"
      end

      def setup_join_map
        @target_mapping = Mapping.new(@mapping.mappings, @target, @target_mapping_name)

        # Builds a hash of Source Key Field -> Anonymous Key Field
        @key_field_map = (mapping.keys.entries + associated_mapping.keys.entries).inject({}) do |map, key_field|
          type = case key_field.type
            when Clipper::Types::Serial then
              Clipper::Types::Integer
            else
              key_field.type
            end

          join_key_field_name = key_field_name(key_field)

          map[key_field] = target_mapping.field(join_key_field_name, type, key_field.default)

          # Define a getter on the join model that always gets the latest key from the associated models
          if key_field.mapping == mapping
            @target.send(:define_method, join_key_field_name) do
              if parent
                key_field.get(parent)
              else
                instance_variable_get("@#{map[key_field].name}")
              end
            end
          else
            @target.send(:define_method, join_key_field_name) do
              if child
                key_field.get(child)
              else
                instance_variable_get("@#{map[key_field].name}")
              end
            end
          end

          map
        end

        # Many-To-Many key spans each field in the table
        @target_mapping.key(*@key_field_map.values)

        # Register our "anonymous" mapping
        mapping.mappings << @target_mapping
      end

      # The "parent" mapping
      def mapping
        @mapping
      end

      def associated_mapping
        @mapping.mappings[@mapped_name]
      end

      def target_mapping
        @target_mapping
      end

      def target
        @target
      end

      def set_key(parent, child, link)
        mapping.keys.each do |key_field|
          @key_field_map[key_field].set(link, key_field.get(parent))
        end

        associated_mapping.keys.each do |key_field|
          @key_field_map[key_field].set(link, key_field.get(child))
        end
      end

      # def unlink(parent, child)
      #   mapping_criteria = Clipper::Query::Criteria.new(self.mapping)
      #   criteria = self.match_criteria.call(mapping_criteria, Clipper::Query::Criteria.new(self.associated_mapping))
      # 
      #   c = criteria.__conditions__
      #   c.field.set(child, nil)
      # end

      def load_links(instance)
        criteria = Clipper::Query::Criteria.new(self.target_mapping)
        self.mapping.keys.each do |key_field|
          join_key_field = @key_field_map[key_field]

          criteria.send(join_key_field.name.to_sym).send(:eq, key_field.get(instance))
        end

        instance.__session__.find(self.target, criteria.__options__, criteria.__conditions__)
      end

      # TODO: This can be boiled down to a join, and would be much more reliable, and most
      # likely less buggy
      def load(instance)
        links = load_links(instance)

        # Run through each linked item, build query to get list of associated items
        criteria = Clipper::Query::Criteria.new(self.associated_mapping)

        links.each do |link|
          # TODO: Make this work for models with CPK, this is a bug
          self.associated_mapping.keys.map do |key_field|
            criteria.send(key_field.name.to_sym).send(:eq, link.send(@key_field_map[key_field].name))
          end
        end

        instance.__session__.find(self.associated_mapping, criteria.__options__, criteria.__conditions__)
      end

      def to_s
        "<#{self.class.name} Mapping: #{mapping.name} many_to_many #{name}>"
      end

      def instance_variable_name
        "@__#{self.name}_collection__"
      end

      def self.bind!(association, target)
        target.send(:define_method, association.getter) do

          if data = instance_variable_get(association.instance_variable_name)
            data
          else
            if __session__
              instance_variable_set(association.instance_variable_name, ManyToManyCollection.new(association, self, association.load(self), []))
            else
              instance_variable_set(association.instance_variable_name, ManyToManyCollection.new(association, self, [], [])) #Collection.new(association.associated_mapping, [])))
            end
          end

        end

        target.send(:define_method, association.setter) do |new_value|
          raise ArgumentError.new("#{self.class}.#{association.setter} only accepts enumerables") unless new_value.is_a?(Enumerable)

          if __session__
            association.load_links(self).each do |link|
              __session__.delete(link)
            end
          end

          collection = ManyToManyCollection.new(association, self, [], [])

          new_value.each do |item|
            association_link = association.target.new(self, item)
            # association.set_key(self, item, association_link)
            # self.__session__.enlist(association_link) if self.__session__

            collection.add(item, association_link)
          end

          instance_variable_set(association.instance_variable_name, collection)
        end
      end
    end

  end
end