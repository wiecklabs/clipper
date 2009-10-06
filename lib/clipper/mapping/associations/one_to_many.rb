module Clipper
  class Mapping

    class OneToManyCollection < ::Clipper::Collection

      def initialize(association, parent, children = nil)
        @loaded = !children.nil?
        children = [] if children.nil?
        
        @association = association
        @parent = parent
        @to_enlist = @collection = children
        @mapping = association.associated_mapping
      end

      def loaded?
        @loaded
      end

      def add(item)
        super

        if @parent.__session__
          @association.set_key(@parent, item)
          @parent.__session__.enlist(item)
        else
          @to_enlist << item
        end

        item
      end
      alias << add

      def each_to_enlist
        @to_enlist.each { |item| yield item }
        self
      end

      def finished_enlisting!
        @to_enlist = []
      end

      def each
        load! unless loaded?
        @collection.each { |item| yield item }
      end

      def size
        load! unless loaded?
        @collection.size
      end

      protected

      def load!
        if @parent.__session__
          criteria = @association.match_criteria.call(@parent, Clipper::Query::Criteria.new(@mapping))

          @collection = @parent.__session__.find(@mapping, criteria.__options__, criteria.__conditions__) | @to_enlist
        end

        @loaded = true
      end
    end

    class OneToMany < Association
      attr_reader :match_criteria

      def initialize(mapping, name, mapped_name, &match_criteria)
        raise ArgumentError.new("You must pass a block containing a criteria expression for '#{mapping.name} has_many #{name}'") unless match_criteria

        @mapping = mapping
        @name = name
        @mapped_name = mapped_name
        @match_criteria = match_criteria
      end

      def associated_mapping
        @mapping.mappings[@mapped_name]
      end

      # Set the child's foreign key value to the parent_item's primary key value
      def set_key(parent, child)
        mapping_criteria = Clipper::Query::Criteria.new(self.mapping)
        criteria = self.match_criteria.call(mapping_criteria, Clipper::Query::Criteria.new(self.associated_mapping))

        conditions = criteria.__conditions__
        conditions.field.accessor.set(child, conditions.value.field.accessor.get(parent))
      end

      def unlink(parent, child)
        mapping_criteria = Clipper::Query::Criteria.new(self.mapping)
        criteria = self.match_criteria.call(mapping_criteria, Clipper::Query::Criteria.new(self.associated_mapping))

        conditions = criteria.__conditions__
        conditions.field.accessor.set(child, nil)
      end

      def load(instance)
        criteria = self.match_criteria.call(instance, Clipper::Query::Criteria.new(self.associated_mapping))

        instance.__session__.find(self.associated_mapping, criteria.__options__, criteria.__conditions__)
      end

      def to_s
        "<#{self.class.name} Mapping: #{mapping.name} have_many #{name}>"
      end

      def instance_variable_name
        "@__#{self.name}_collection__"
      end

      def self.bind!(association, target)
        target.send(:define_method, association.getter) do

          if data = instance_variable_get(association.instance_variable_name)
            data
          else
            instance_variable_set(association.instance_variable_name, OneToManyCollection.new(association, self))
          end
        end

        target.send(:define_method, association.setter) do |new_value|
          raise ArgumentError.new("#{self.class}.#{association.setter} only accepts enumerables") unless new_value.is_a?(Enumerable)

          if __session__ and (items = self.send(association.getter))
            items.each do |item|
              association.unlink(self, item)
              __session__.enlist(item)
            end
          end

          if self.__session__
            new_value.each do |item|
              association.set_key(self, item)
              __session__.enlist(item)
            end
          end

          instance_variable_set(association.instance_variable_name, OneToManyCollection.new(association, self, new_value))
        end
      end
    end
  end
end