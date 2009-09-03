module Clipper
  module Accessors

    class StringSerializer
      def self.load(value)
        value.to_s
      end
    end

    class IntegerSerializer
      def self.load(value)
        Integer(value)
      end
    end

    class BooleanSerializer
      def self.load(value)
        if value.nil? or value == false or value == 0
          return false
        else
          return true
        end
      end
    end

    class TypedAccessor
      include Clipper::Types

      ##
      # Defines mappings from native types to Clipper Serializers.
      # 
      # @api private
      ##
      @@native_serializers = {
        String => Clipper::Accessors::StringSerializer,
        Integer => Clipper::Accessors::IntegerSerializer,
        Boolean => Clipper::Accessors::BooleanSerializer
      }.freeze

      attr_reader :target, :name, :type

      def initialize(target, name, type)
        raise ArgumentError.new("+target+ must be a Class") unless target.is_a?(Class)
        raise ArgumentError.new("+target+ must include the Accessors module") unless Accessors > target
        raise ArgumentError.new("+name+ must be a Symbol") unless name.is_a?(Symbol)
        raise ArgumentError.new("+type+ must be a serializable Class") unless type.is_a?(Class)

        @target = target
        @name = name
        @type = type

        self.class.define_accessor(target, name)
      end

      def typecast(value)
        return value if value.is_a?(@type)

        case
        when @type === value then value
        when serializer = @@native_serializers[@type] then serializer.load(value)
        when Serializable > @type then @type.load(value)
        else
          raise SerializationError.new(type, value)
        end
      end

      def self.define_accessor(target, name)
        # String evals produce faster code than define_method calls (in MRI).
        # TODO: Confirm this is still true in JRuby.
        target.class_eval <<-EOS
          def #{name}
            self.class.accessors[#{name.inspect}].typecast(@#{name})
          end
          
          def #{name}=(value)
            @#{name} = self.class.accessors[#{name.inspect}].typecast(value)
          end
        EOS
      end

      def set(instance, value)
        instance.send(:instance_variable_set, "@#{name}", value)
      end

      def get(instance)
        instance.send(:instance_variable_get, "@#{name}")
      end

      def hash
        [@target, @name, @type].hash
      end

      def eql?(other)
        other.is_a?(TypedAccessor) &&
          @target == other.target &&
          @name == other.name &&
          @type == other.type
      end
      alias == eql?

    end

    private

    class SerializationError < StandardError
      def initialize(type, value)
        super("Don't know how to serialize #{value.inspect} to #{type.inspect}")
      end
    end
  end
end