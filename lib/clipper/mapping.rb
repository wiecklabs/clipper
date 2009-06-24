module Clipper
  class Mapping

    def self.map(session, target, name)
      mapping = new(session, target, name)
      yield mapping
      mapping
    end

    attr_reader :signatures, :accessors, :types

    def initialize(session, target, name)
      unless session.is_a?(Clipper::Session) && target.is_a?(Class) && name.is_a?(String)
        raise ArgumentError.new("Expected [Clipper::Session<session>, Class<target>, String<name>] but got #{[session.class, target.class, name.class].inspect}")
      end

      unless Clipper::Accessors > target
        raise ArgumentError.new("Mapped class #{target.inspect} must include Clipper::Accessors")
      end

      @session = session
      @target = target
      @name = name

      @signatures = java.util.LinkedHashSet.new
      @accessors = java.util.LinkedHashSet.new
      @types = java.util.LinkedHashSet.new
    end

    def type_map
      @session.repository.class.type_map
    end

    def field(field_name, *repository_types)
      unless accessor = @target.accessors[field_name]
        raise ArgumentError.new("#{field_name.inspect} has not been delcared as an accessor on #{@target}")
      end

      if repository_types.any? { |type| type.is_a?(Class) }
        raise ArgumentError.new("Mapping#field expects only type instances, but got: #{repository_types.inspect}")
      end

      signature = type_map.match([accessor.type], repository_types.map { |type| type.class })

      @signatures << signature
      @accessors << accessor
      @types << repository_types
    end

    def key(*field_names)
      raise ArgumentError.new("The key for Mapping<#{@name}> is already defined as #{@key.inspect}") if @keys

      missing_fields = field_names.reject { |field_name| @accessors.any? { |accessor| accessor.name == field_name } }

      unless missing_fields.empty?
        raise ArgumentError.new("#{missing_fields.inspect} have not been delcared as fields.")
      end

      @keys = field_names
    end

  end
end