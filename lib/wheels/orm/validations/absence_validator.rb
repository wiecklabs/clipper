module Wheels
  module Orm
    module Validations
      
      class AbsenceValidator
        def initialize(field)
          @field = field
        end
        
        def call(instance, errors)
          unless instance.send(@field).blank?
            errors.append(instance, "%1$s should be absent." % [@field], @field)
          end
        end
      end
      
    end # module Validations
  end # module Orm
end # module Wheels