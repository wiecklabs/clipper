module Wheels
  module Orm
    module Mappings
      class Field

        include Test::Unit::Assertions

        def initialize(mapping, name, type)
          begin
            assert_kind_of(Wheels::Orm::Mappings::Mapping, mapping, "Field#mapping must be a Mapping")
            @mapping = mapping

            assert_kind_of(String, name, "Field#name must be a String")
            assert_not_blank(name, "Field#name must not be blank")
            @name = name

            type = Wheels::Orm::Types[type.to_s]
            assert_descendant_of(Wheels::Orm::Type, type, "Field#type must be a Wheels::Orm::Type")
            @type = type
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end
        end

        def mapping
          @mapping
        end

        def name
          @name
        end

        def type
          @type
        end

        def eql?(other)
          other.is_a?(Field) && mapping == other.mapping && type == other.type && name == other.name
        end
        alias == eql?

        def hash
          @hash ||= [name, type].hash
        end
      end
    end
  end
end