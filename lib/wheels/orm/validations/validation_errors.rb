module Wheels
  module Orm
    module Validations
      
      class ValidationErrors
        def initialize
          @errors = Set.new
        end
        
        def append(instance, message, *fields)
          error = ValidationError.new(instance, message, *fields)
          @errors << error
          error
        end
        
        def empty?
          @errors.empty?
        end
      end # class ValidationErrors
      
    end # module Validations
  end # module Orm
end # module Wheels