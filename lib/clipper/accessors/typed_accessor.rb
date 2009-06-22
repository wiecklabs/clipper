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

    class TypedAccessor

      ##
      # Defines mappings from native types to Clipper Serializers.
      # 
      # @api private
      ##
      @@native_serializers = {
        String => Clipper::Accessors::StringSerializer,
        Integer => Clipper::Accessors::IntegerSerializer
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
          raise SerializationError.new("Don't know how to serialize #{@type.inspect}")
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

      private

      class SerializationError < StandardError
      end

    end
  end
end