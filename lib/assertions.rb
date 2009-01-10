module Test
  module Unit
    module Assertions
      
      def assert_descendant_of(type, value, message)
        assert(value.is_a?(Class) && value < type, message)
      end
    end
  end
end