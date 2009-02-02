module Test
  module Unit
    module Assertions

      def assert_descendant_of(type, value, message = "Expected #{value} to be a descendant of #{type}")
        assert(value.is_a?(Class) && value < type, message)
      end

      def assert_not_blank(value, message)
        assert(!value.blank?, message)
      end
      
      def assert_empty(value)
        assert(value.empty?, "Expected #{value.inspect} to be empty")
      end
      
      def assert_not_empty(value)
        assert(!value.empty?, "Expected #{value.inspect} to not be empty")
      end
    end
  end
end