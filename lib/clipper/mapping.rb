module Clipper
  class Mapping

    def self.map(session, mapped_class, table_name)
      mapping = new(session, mapped_class, table_name)
      yield mapping
      mapping
    end

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
    end

    def field(field_name, *repository_types)
      unless accessor = @mapped_class.accessors[field_name]
        raise ArgumentError.new("Mappings#field can only map fields declared as accessors")
      end
    end

  end
end