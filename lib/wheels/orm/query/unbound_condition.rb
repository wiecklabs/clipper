module Wheels
  module Orm
    class Query
      class UnboundCondition
        def self.gt(field, value)
          new(:gt, field, value)
        end

        def self.lt(field, value)
          new(:lt, field, value)
        end

        def self.eq(field, value)
          new(:eq, field, value)
        end

        def initialize(operator, field, value)
          @operator = operator
          @field = field
          @value = value
        end

        def field
          @field
        end

        def value
          @value
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