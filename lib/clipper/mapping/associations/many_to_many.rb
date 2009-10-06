module Clipper
  class Mapping

    class ManyToManyCollection < ::Clipper::Collection

      def initialize(association, parent, children = nil)
        @loaded = !children.nil?
        children = [] if children.nil?
        
        @association = association
        @parent = parent
        @collection = children
        @links = []
        @to_enlist = []
        @mapping = association.associated_mapping
      end

      def loaded?
        @loaded
      end

      def add(item)
        @collection << item
        link = @association.target.new(@parent, item)

        if @parent.__session__
          @parent.__session__.enlist(item)
          @parent.__session__.enlist(link)
        else
          @to_enlist << item
          @links << link
        end

        @association.set_key(@parent, item, link)

        item
      end
      alias << add

      def each_to_enlist
        @to_enlist.zip(@links).each do |item, link|
          yield item, link
        end
        self
      end

      def finished_enlisting!
        @to_enlist = []
        @links = []
      end

      def size
        load! unless loaded?
        @collection.size
      end

      def each
        load! unless loaded?
        @collection.each { |item| yield item }
      end

      protected

      def load!
        if @parent.__session__
          @collection = @association.load(@parent) | @to_enlist
        end

        @loaded = true
      end

    end

    class ManyToMany < Association

      def initialize(repository, mapping, name, mapped_name, target_mapping_name)
        @repository = repository
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
        rescue Clipper::Mapping::UnmappedClassError
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

#      class ValueProxy < Clipper::Mapping::ValueProxy
#        def initialize(type, instance, join_field, key_field)
#          @type = type
#          @instance = instance
#          @join_field = join_field
#          @key_field = key_field
#          super(join_field)
#        end
#
#        def get
#          @instance.send(@type) ? set(@key_field.get(@instance.send(@type))) : @value
#        end
#
#      end

      def setup_join_map
        @repository.mappings[@target] = @target_mapping = Clipper::Mapping.map(@repository, @target, @target_mapping_name)
        keys = []

        # Builds a hash of Source Key Field -> Anonymous Key Field
        key_field_map = @key_field_map = (mapping.keys.entries + associated_mapping.keys.entries).inject({}) do |map, key_field|
          join_key_field_name = key_field_name(key_field)
          
          type = if key_field.type.is_a?(@repository.class::Types::Serial)
            @repository.class::Types::Integer.new
          else
            key_field.type
          end

          target_mapping.property(join_key_field_name.to_sym, key_field.accessor.type, type)#.default)

          map[key_field] = target_mapping[join_key_field_name.to_sym]
          keys << join_key_field_name.to_sym
          map
        end

        mapping = self.mapping

        # We don't want to break how field.value(instance) works, so we need to replace
        # the ValueProxy with our own. But since we don't have initialization hooks,
        # we need to set them when they're accessed. Ugly. Works.
        @target.send(:define_method, :instance_variable_get) do |name|
          var = super

          key_field, join_key_field = nil

          if !var && key_field_map.detect { |key_field, join_key_field| "@#{join_key_field.name}" == name }
            var = key_field.accessor.get(self.send((key_field.mapping == mapping ? :parent : :child)))
            instance_variable_set("@#{join_key_field.name}", var)
          end

          var
        end

        # Many-To-Many key spans each field in the table
        @target_mapping.key(*keys)
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
          @key_field_map[key_field].accessor.set(link, key_field.accessor.get(parent))
        end

        associated_mapping.keys.each do |key_field|
          @key_field_map[key_field].accessor.set(link, key_field.accessor.get(child))
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

          criteria.send(join_key_field.name.to_sym).send(:eq, key_field.accessor.get(instance))
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
            instance_variable_set(association.instance_variable_name, ManyToManyCollection.new(association, self))
          end

        end

        target.send(:define_method, association.setter) do |new_value|
          raise ArgumentError.new("#{self.class}.#{association.setter} only accepts enumerables") unless new_value.is_a?(Enumerable)

          if __session__
            association.load_links(self).each do |link|
              __session__.delete(link)
            end
          end

          collection = ManyToManyCollection.new(association, self)

          new_value.each do |item|
            collection << item
          end

          instance_variable_set(association.instance_variable_name, collection)
        end
      end
    end

  end
end