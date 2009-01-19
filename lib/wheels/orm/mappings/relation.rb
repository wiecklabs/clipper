module Wheels
  module Orm
    module Mappings
      class Relation

        include Test::Unit::Assertions

        def initialize(key, reference)
          begin
            # Breaks CPK...
            assert_kind_of(Field, key, "Relation#key must be a Wheels::Orm::Mappings::Field")
            @key = key
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end

          begin
            assert_kind_of(Field, target, "Relation#reference must be a Wheels::Orm::Mappings::Field")
            @reference = reference
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end
        end

        def key
          @key
        end

        def reference
          @reference
        end

        def eql?(other)
          other.is_a?(Relation) && key == other.key && reference == other.reference
        end

        def hash
          @hash ||= [key, reference].hash
        end
      end
    end
  end
end