module Wheels
  module Orm
    module Helpers
      def self.blank?(value)
        case value
        when NilClass then true
        when String then value =~ /^\s*$/
        else raise ArgumentError.new("Don't know how to check for blankness of a #{value.class}. value: #{value.inspect}")
        end
      end
    end
  end
end