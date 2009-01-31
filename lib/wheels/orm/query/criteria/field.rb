module Wheels
  module Orm
    class Query
      class Criteria
        class Field
          
          def initialize(criteria, field)
            @criteria = criteria
            @field = field
          end
          
          def eq(value)
            @criteria.conditions << Wheels::Orm::Query::Condition.new(:eq, @field, value)
            @criteria
          end
          
          def lt(value)
            @criteria.conditions << Wheels::Orm::Query::Condition.new(:lt, @field, value)
            @criteria
          end
          
          def gt(value)
            @criteria.conditions << Wheels::Orm::Query::Condition.new(:gt, @field, value)
            @criteria
          end
          
        end # class Field
      end # class Criteria
    end # class Query
  end # module Orm
end # module Wheels