module Clipper
  class Mappings

    class BelongsTo < Association

      def initialize(mapping, name, mapped_name, &match_criteria)
        @mapping = mapping
        @name = name
        @mapped_name = mapped_name
        @match_criteria = match_criteria
      end

      def associated_mapping
        @mapping.mappings[@mapped_name]
      end

      def instance_variable_name
        "@__#{self.name}_instance__"
      end

      def to_s
        "<#{self.class.name} Mapping: #{mapping.name} belong_to #{name}>"
      end

      def set_key(parent, child)
        mapping_criteria = Clipper::Query::Criteria.new(self.mapping)
        criteria = self.match_criteria.call(mapping_criteria, Clipper::Query::Criteria.new(self.associated_mapping))

        c = criteria.__conditions__
        c.value.field.set(parent, c.field.get(child))
      end

      def self.bind!(association, target)

        target.send(:define_method, association.getter) do
          associated_mapping = association.associated_mapping
          criteria = association.match_criteria.call(self, Clipper::Query::Criteria.new(associated_mapping))

          # TODO: Side effect: Multiple calls w/ a nil association will run the fider each time.
          if data = instance_variable_get(association.instance_variable_name)
            data
          else
            instance_variable_set(association.instance_variable_name, __session__.find(associated_mapping, criteria.__options__, criteria.__conditions__).first)
          end
        end

        target.send(:define_method, association.setter) do |object|
          association.set_key(self, object)
          instance_variable_set(association.instance_variable_name, object)
        end
      end
    end

  end
end