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
        
        def merge(conditions)
          @conditions = conditions
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
        
        def limit(size)
          if !size.is_a?(Integer) || size <= 0
            raise ArgumentError.new("Wheels::Orm::Query::Criteria#limit expects a non-zero Integer for the size")
          end
          @limit = size
        end
        
        def offset(position)
          if !position.is_a?(Integer) || position < 0
            raise ArgumentError.new("Wheels::Orm::Query::Criteria#offset expects a non-negative Integer for the position")
          end
          @offset = position
        end
        
        def order(*fields)
          unless fields.all? { |field| field.is_a?(Criteria::Field)  }
            raise ArgumentError.new("Wheels::Orm::Query::Criteria#order expects a list of Criteria::Field objects")
          end
          @order = fields.map do |proxy|
            [ proxy.field, proxy.direction ]
          end
        end
        
        def __options__
          options = {}
          options[:limit] = @limit if @limit
          options[:offset] = @offset if @offset
          options[:order] = @order if @order
          options.empty? ? nil : options
        end
        
        def __conditions__
          @conditions
        end
      end
    end
  end
end

require Pathname(__FILE__).dirname + "criteria" + "field"