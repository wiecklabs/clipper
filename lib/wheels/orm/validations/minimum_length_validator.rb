module Wheels
  module Orm
    module Validations
      
      class MinimumLengthValidator
        def initialize(field, length)
          @field = field
          @length = length
        end
        
        def call(instance, errors)
          if instance.send(@field).length < @length
            errors.append(instance, "%1$s is too short! Must be longer than %2$s characters." % [@field, @length], "name")
          end
        end
      end
      
    end # module Validations
  end # module Orm
end # module Wheels