module Wheels
  module Orm
    module Accessors
      module Serializable

        class HashReader
          def initialize(values)
            @values = values
          end

          def [](key)
            Value.new(@values[key])
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
  end
end