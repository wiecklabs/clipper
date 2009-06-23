module Clipper
  class Mappings
    class UnmappedClassError < StandardError
    end

    class UnsupportedTypeError < StandardError
      def initialize(type)
        super("#{type.inspect} is not a registered Clipper::Type (#{Clipper::Types.inspect})")
      end
    end

    include Enumerable
    include Hooks

    # This lets us defer mapping of Many-To-Many join-maps
    after :map do |mappings|
      newest_map = mappings.entries.last.target

      while (callback = mappings.map_callbacks[newest_map].shift)
        callback.call(mappings.entries.last)
      end
    end

    class << self
      def [](repository_name)
        @repository_mappings ||= {}
        @repository_mappings[repository_name] ||= Mappings.new
      end
    end

    def initialize
      @mappings = java.util.LinkedHashMap.new

      @map_callbacks = Hash.new { |h, k| h[k] = [] }
    end

    def [](mapped_class)
      @mappings[mapped_class] || raise(UnmappedClassError.new("Mappings#[#{mapped_class}] is not mapped."))
    end

    def <<(mapping)
      raise ArgumentError.new("Mappings#<< must be passed a Mapping") unless mapping.is_a?(Clipper::Mappings::Mapping)
      @mappings[mapping.target] = mapping
    end

    def each
      @mappings.values.each { |mapping| yield mapping }
    end

    def map(target, mapped_name)
      mapping = Clipper::Mappings::Mapping.new(self, target, mapped_name)
      yield mapping
      self << mapping
      mapping
    end

    def map_callbacks
      @map_callbacks
    end

    def register_map_callback(mapped_name, &callback)
      @map_callbacks[mapped_name] << callback
    end


  end
end