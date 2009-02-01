module Wheels
  module Orm
    class Query
      class Criteria
        
        class << self
          alias __new__ new

          def new(mapping)
            unless mapping.is_a?(Wheels::Orm::Mappings::Mapping)
              raise ArgumentError.new("Wheels::Orm::Query::Criteria#initialize requires a Wheels::Orm::Mappings::Mapping")
            end
          
            (@mappings ||= {})[mapping] ||= begin
              
              field_methods = mapping.fields.map do |field|
                <<-EOS
                def #{field.name}
                  Wheels::Orm::Query::Criteria::Field.new(self, self.class.mapping[#{field.name.inspect}])
                end
                EOS
              end.join
              
              Class.new(self) do
                @mapping = mapping
                class_eval field_methods, __FILE__, __LINE__
              end # Class.new
            end.__new__
          end
          
          def mapping
            @mapping
          end
        end # class << self
        
        def merge(condition)
          @condition = condition
          self
        end
        
        def and(*others)
          AndExpression.new(@condition, *others)
          self
        end

        def or(*others)
          OrExpression.new(@condition, *others)
          self
        end
        
        def condition
          @condition
        end
      end
    end
  end
end

require Pathname(__FILE__).dirname + "criteria" + "field"