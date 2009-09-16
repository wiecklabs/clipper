require Pathname(__FILE__).dirname + "type_map" + "signature"
require Pathname(__FILE__).dirname + "type_map" + "signature_helper"
require Pathname(__FILE__).dirname + "type_map" + "repositories_types_helper"

module Clipper
  class TypeMap

    def initialize
      @signatures = java.util.LinkedHashSet.new
    end

    def <<(signature)
      unless signature.is_a?(Clipper::TypeMap::Signature)
        raise ArgumentError.new("Expected signature to be a #{self.class}::Signature but was #{signature.inspect}")
      end

      @signatures << signature
    end

    def size
      @signatures.size
    end

    def match(attribute_types, repository_types)
      match = @signatures.detect do |signature|
        signature.match?(attribute_types, repository_types)
      end

      if match
        match
      else
        raise MatchError.new(attribute_types, repository_types)
      end
    end

    class MatchError < StandardError
      def initialize(attribute_types, repository_types)
        super "No matching Signature found for #{attribute_types.inspect}:#{repository_types.inspect}"
      end
    end
  end # class TypeMap
end # module Clipper