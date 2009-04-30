module Beacon
  module Validations
    
    class MaximumLengthValidator
      def initialize(field, length)
        @field = field
        @length = length
      end
      
      def call(instance, errors)
        if instance.send(@field).length > @length
          errors.append(instance, "%1$s is too long! Must %2$s characters or shorter." % [@field, @length], @field)
        end
      end
    end
    
  end # module Validations
end # module Beacon