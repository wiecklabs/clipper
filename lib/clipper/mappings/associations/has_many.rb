module Clipper
  class Mappings

    class HasManyCollection < ::Clipper::Collection

      def initialize(association, parent, children)
        @association = association
        @parent = parent
        @collection = children
        @mapping = association.associated_mapping
      end

      def add(item)
        super
        @association.set_key(@parent, item)

        item
      end
      alias << add

    end

    class HasMany < Association

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

        c = criteria.__conditions__
        c.field.set(child, c.value.field.get(parent))
      end

      def to_s
        "<#{self.class.name} Mapping: #{mapping.name} have_many #{name}>"
      end

      def self.bind!(association, target)
        target.send(:define_method, association.name) do
          associated_mapping = association.associated_mapping
          criteria = association.match_criteria.call(self, Clipper::Query::Criteria.new(associated_mapping))

          if data = instance_variable_get("@__#{association.name}_collection__")
            data
          else
            if __session__
              data = __session__.find(associated_mapping, criteria.__options__, criteria.__conditions__)
              instance_variable_set("@__#{association.name}_collection__", HasManyCollection.new(association, self, data))
            else
              instance_variable_set("@__#{association.name}_collection__", HasManyCollection.new(association, self, Collection.new(association.associated_mapping, [])))
            end
          end
        end
      end
    end

  end
end