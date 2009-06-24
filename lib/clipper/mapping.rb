module Clipper
  class Mapping

    def self.map(session, mapped_class, table_name)
      mapping = new(session, mapped_class, table_name)
      yield mapping
      mapping
    end

    attr_reader :signatures, :accessors, :types

    def initialize(session, mapped_class, table_name)
      unless session.is_a?(Clipper::Session) && mapped_class.is_a?(Class) && table_name.is_a?(String)
        raise ArgumentError.new("Expected [Clipper::Session<session>, Class<mapped_class>, String<table_name>] but got #{[session.class, mapped_class.class, table_name.class].inspect}")
      end

      unless Clipper::Accessors > mapped_class
        raise ArgumentError.new("Mapped class #{mapped_class.inspect} must include Clipper::Accessors")
      end

      @session = session
      @mapped_class = mapped_class
      @table_name = table_name

      @signatures = java.util.LinkedHashSet.new
      @accessors = java.util.LinkedHashSet.new
      @types = java.util.LinkedHashSet.new
    end

    def type_map
      @session.repository.class.type_map
    end

    def field(field_name, *repository_types)
      unless accessor = @mapped_class.accessors[field_name]
        raise ArgumentError.new("Mappings#field can only map fields declared as accessors")
      end

      if repository_types.any? { |type| type.is_a?(Class) }
        raise ArgumentError.new("Mappings#field only accepts type instances")
      end

      signature = type_map.match([accessor.type], repository_types.map { |type| type.class })

      @signatures << signature
      @accessors << accessor
      @types << repository_types
    end

  end
end