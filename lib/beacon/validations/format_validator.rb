module Beacon
  module Validations
    
    class FormatValidator < Validator
      def initialize(field, format, message = "%1$s is not formatted properly.")
        @field = field
        @format = format
        @message = message
      end
      
      def call(instance, errors)
        unless instance.send(@field) =~ @format
          errors.append(instance, @message % [@field], @field)
        end
      end
    end
    
  end # module Validations
end # module Beacon