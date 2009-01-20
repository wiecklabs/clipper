module Wheels
  module Orm
    class Mappings
      class Field

        include Test::Unit::Assertions

        def initialize(mapping, name, type)
          begin
            assert_kind_of(Wheels::Orm::Mappings::Mapping, mapping, "Field#mapping must be a Mapping")
            @mapping = mapping

            assert_kind_of(String, name, "Field#name must be a String")
            assert_not_blank(name, "Field#name must not be blank")
            @name = name

            if type.is_a?(Class)
              type = Wheels::Orm::Types[type.to_s].new
            end

            assert_descendant_of(Wheels::Orm::Type, type.class, "Field#type must be a Wheels::Orm::Type")
            @type = type
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end
        end

        def self.bind!(field, target)
          target.class_eval <<-EOS
            def #{field.name}
              @#{field.name} ||= orm.load(self, #{field.name.inspect})
            end

            def #{field.name}=(value)
              @#{field.name} = value
            end
          EOS
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
          other.is_a?(Field) && mapping == other.mapping && type.class == other.type.class && name == other.name
        end
        alias == eql?

        def hash
          @hash ||= [name, type].hash
        end
      end
    end
  end
end