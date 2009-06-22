require Pathname(__FILE__).dirname + "type_map" + "signature"

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
  end # class TypeMap
end # module Clipper