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
                  Wheels::Orm::Query::Criteria::Field.new(self, self.class.mapping[#{field.name}])
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

        def initialize
          @conditions = java.util.LinkedHashSet.new
        end
        
        def and(*others)
          AndExpression.new(self, *others)
        end

        def or(*others)
          @conditions.reject! { |condition| others.include?(condition) }
          puts "OR: @conditions => #{@conditions.inspect}, others => #{others.inspect}"
          @conditions << OrExpression.new(@conditions.pop, *others)
          self
        end

        def conditions
          @conditions
        end
      end
    end
  end
end

require Pathname(__FILE__).dirname + "criteria" + "field"