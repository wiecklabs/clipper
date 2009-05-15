module Clipper
  class Mappings

    class OneToManyCollection < ::Clipper::Collection

      def initialize(association, parent, children)
        @association = association
        @parent = parent
        @collection = children
        @mapping = association.associated_mapping
      end

      def add(item)
        super

        @parent.__session__.enlist(item) if @parent.__session__
        @association.set_key(@parent, item)

        item
      end
      alias << add

    end

    class OneToMany < Association

      def initialize(mapping, name, mapped_name, &match_criteria)
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
        p conditions
        conditions.field.set(child, conditions.value.field.get(parent))
      end

      def unlink(parent, child)
        mapping_criteria = Clipper::Query::Criteria.new(self.mapping)
        criteria = self.match_criteria.call(mapping_criteria, Clipper::Query::Criteria.new(self.associated_mapping))

        conditions = criteria.__conditions__
        conditions.field.set(child, nil)
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
            if __session__
              instance_variable_set(association.instance_variable_name, OneToManyCollection.new(association, self, association.load(self)))
            else
              instance_variable_set(association.instance_variable_name, OneToManyCollection.new(association, self, [])) #Collection.new(association.associated_mapping, [])))
            end
          end
        end

        target.send(:define_method, association.setter) do |new_value|
          raise ArgumentError.new("#{self.class}.#{association.setter} only accepts enumerables") unless new_value.is_a?(Enumerable)

          if items = self.send(association.getter)
            if __session__
              items.each do |item|
                association.unlink(self, item)
                __session__.enlist(item)
              end
            end
          end

          new_value.each do |item|
            association.set_key(self, item)
            self.__session__.enlist(item) if self.__session__
          end

          instance_variable_set(association.instance_variable_name, OneToManyCollection.new(association, self, new_value))
        end
      end
    end

  end
end