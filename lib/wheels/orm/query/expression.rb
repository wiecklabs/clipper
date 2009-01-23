module Wheels
  module Orm
    class Query
      class Expression
        def initialize(*values)
          @values = values
        end

        def values
          @values
        end

        def or(*values)
          OrExpression.new(self, *values)
        end

        def and(*values)
          AndExpression.new(self, *values)
        end

        def to_a
          [self.class.operator, *@values.map { |value| value.to_a }]
        end

        private
        def self.operator
          raise NotImplementedError.new("Expression is an abstract class")
        end
      end

      class AndExpression < Expression
        private
        def self.operator
          :and
        end
      end

      class OrExpression < Expression
        private
        def self.operator
          :or
        end
      end
    end
  end
end