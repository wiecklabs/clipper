module Test
  module Unit
    module Assertions
      
      def assert_descendant_of(type, value, message = "Expected #{value} to be a descendant of #{type}")
        assert(value.is_a?(Class) && value < type, message)
      end
      
      def assert_not_blank(value, message)
        assert(!value.blank?, message)
      end
    end
  end
end