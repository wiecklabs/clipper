module Wheels
  module Orm
    class Mappings
      class UnmappedClassError < StandardError
      end

      def initialize
        @mappings = {}
      end

      def [](mapped_class)
        @mappings[mapped_class] || raise(UnmappedClassError.new("Mappings#[#{mapped_class}] is not mapped."))
      end

      def <<(mapping)
        raise ArgumentError.new("Mappings#<< must be passed a Mapping") unless mapping.is_a?(Wheels::Orm::Mappings::Mapping)
        @mappings[mapping.target] = mapping
      end
    end
  end
end