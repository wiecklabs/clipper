module Wheels
  module Orm
    module Validations
      
      class AcceptanceValidator
        def initialize(field)
          @field = field
        end
        
        def call(instance, errors)
          if instance.send(@field).blank?
            errors.append(instance, "You must accept %1$s." % [@field], @field)
          end
        end
      end
      
    end # module Validations
  end # module Orm
end # module Wheels