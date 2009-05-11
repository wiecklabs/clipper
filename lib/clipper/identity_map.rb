module Clipper
  class IdentityMap
    def initialize
      @map = java.util.LinkedHashSet.new
    end

    def add(instance)
      @map << instance.hash
    end

    def remove(instance)
      @map.remove(instance.hash)
    end

    def include?(instance)
      @map.include?(instance.hash)
    end
  end
end # module Clipper
