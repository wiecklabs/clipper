module Clipper
  module Validations
    
    class MinimumLengthValidator < Validator
      def initialize(field, length)
        @field = field
        @length = length
      end
      
      def call(instance, errors)
        if instance.send(@field).length < @length
          errors.append(instance, "%1$s is too short! Must %2$s characters or longer." % [@field, @length], @field)
        end
      end
    end
    
  end # module Validations
end # module Clipper