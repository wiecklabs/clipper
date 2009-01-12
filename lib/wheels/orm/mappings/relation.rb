module Wheels
  module Orm
    module Mappings
      class Relation

        include Test::Unit::Assertions

        def initialize(target, reference)
          begin
            assert_kind_of(Field, target, "Relation#target must be a Wheels::Orm::Mappings::Field")
            @target = target
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

        def target
          @target
        end

        def reference
          @reference
        end

        def eql?(other)
          other.is_a?(Relation) && target == other.target && reference == other.reference
        end

        def hash
          @hash ||= [target, reference].hash
        end
      end
    end
  end
end