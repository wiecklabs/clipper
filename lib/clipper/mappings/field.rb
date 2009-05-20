module Clipper
  class Mappings
    class Field

      def initialize(mapping, name, type, default = nil)
        raise ArgumentError.new("Field#mapping must be a Mapping") unless mapping.kind_of?(Clipper::Mappings::Mapping)
        @mapping = mapping

        raise ArgumentError.new("Field#name must be a String") unless name.is_a?(String)
        raise ArgumentError.new("Field#name must not be blank") if name.blank?
        @name = name

        if type.is_a?(Class)
          if defined_type = Clipper::Types[type.to_s]
            type = defined_type.new
          else
            raise Clipper::Mappings::UnsupportedTypeError.new(type)
          end
        end

        raise ArgumentError.new("Field#type must be a Clipper::Type") unless type.is_a?(Clipper::Type)
        @type = type

        @default = default
      end

      def self.bind!(field, target)

        target.class_eval do
          define_method(field.name) do
            if instance_variable_get("@#{field.name}").nil?
              instance_variable_set("@#{field.name}", field.default_value(self))
            else
              instance_variable_get("@#{field.name}")
            end
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
        unless object.is_a?(@mapping.target)
          raise ArgumentError.new(
            "Field#get (#{mapping.name}.#{self.name}) must receive an instance of #{@mapping.target} but recieved #{object.inspect}"
          )
        end

        object.send(self.name)
      end

      def set(object, value)
        unless object.is_a?(@mapping.target)
          raise ArgumentError.new(
            "Field#set must receive an instance of #{@mapping.target} but recieved #{object.inspect}"
          )
        end

        object.instance_variable_set("@#{self.name}", value)
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

      def default
        @default
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