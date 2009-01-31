module Wheels
  module Orm
    class Query
      class Criteria
        
        def initialize(mapping)
          unless mapping.is_a?(Wheels::Orm::Mappings::Mapping)
            raise ArgumentError.new("Wheels::Orm::Query::Criteria#initialize requires a Wheels::Orm::Mappings::Mapping")
          end
          @mapping = mapping
          
          (class << self; self end).class_eval do
            mapping.fields.each do |field|
              define_method(field.name) do
                nil
              end
            end
          end
        end
        

        def and(*others)
          AndExpression.new(self, *others)
        end

        def or(*others)
          OrExpression.new(self, *others)
        end

        def to_a
          [@operator, @field, @value]
        end
      end
    end
  end
end