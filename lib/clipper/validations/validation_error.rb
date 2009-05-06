module Clipper
  module Validations
    
    class ValidationError
      attr_reader :instance, :message, :fields
      
      def initialize(instance, message, *fields)
        @instance = instance
        @message = message
        @fields = fields
      end
    end # class ValidationError
    
  end # module Validations
end # module Clipper