module Wheels
  module Orm
    class Mappings
      class Field

        def initialize(mapping, name, type, default = nil)
          raise ArgumentError.new("Field#mapping must be a Mapping") unless mapping.kind_of?(Wheels::Orm::Mappings::Mapping)
          @mapping = mapping

          raise ArgumentError.new("Field#name must be a String") unless name.is_a?(String)
          raise ArgumentError.new("Field#name must not be blank") if name.blank?
          @name = name

          if type.is_a?(Class)
            if defined_type = Wheels::Orm::Types[type.to_s]
              type = defined_type.new
            else
              raise Wheels::Orm::Mappings::UnsupportedTypeError.new(type)
            end
          end

          raise ArgumentError.new("Field#type must be a Wheels::Orm::Type") unless type.is_a?(Wheels::Orm::Type)
          @type = type

          @default = default
        end

        def self.bind!(field, target)

          target.class_eval do
            define_method(field.name) do
              instance_variable_get("@#{field.name}") || instance_variable_set("@#{field.name}", field.default_value(self))
            end

            define_method("#{field.name}=") do |value|
              instance_variable_set("@#{field.name}", value)
            end
          end

        end

        def default_value(object)
          @default.is_a?(Proc) ? @default.call(object) : @default
        end

        def get(object)
          raise ArgumentError.new("Field#get must receive an instance of its declared Mapping target") unless object.is_a?(@mapping.target)

          object.send(self.name)
        end

        def set(object, value)
          raise ArgumentError.new("Field#get must receive an instance of its declared Mapping target") unless object.is_a?(@mapping.target)

          object.send(self.name + "=", value)
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