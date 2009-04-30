module Beacon
  class Mappings
    class Relation

      def initialize(key, reference)

        # Breaks CPK...
        raise ArgumentError.new("Relation#key must be a Beacon::Mappings::Field") unless key.is_a?(Field)
        @key = key

        raise ArgumentError.new("Relation#reference must be a Beacon::Mappings::Field") unless reference.is_a?(Field)
        @reference = reference
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