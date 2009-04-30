module Beacon
  module Accessors
    module Serializable

      class EmptyReader
        def [](key)
          Value.new(nil)
        end
      end

      class HashReader
        def initialize(values)
          @values = values
        end

        def [](key)
          Value.new(@values[key])
        end
      end

      class Value
        def initialize(value)
          @value = value
        end

        def value
          @value
        end
      end
    end
  end
end