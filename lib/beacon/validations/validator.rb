module Beacon
  module Validations

    class Validator

      attr_accessor :precondition_block

      def should_run?(instance)
        return true unless @precondition_block

        @precondition_block.call(instance)
      end

      def call(instance, errors)
        raise NotImplementedError.new("Validator#call should be implemented in a concrete class")
      end
    end

  end
end
