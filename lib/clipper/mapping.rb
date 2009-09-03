module Clipper
  class Mapping

    def self.map(repository, target, name)
      mapping = new(repository, target, name)
      yield mapping if block_given?
      mapping
    end

    def [](field_name)
      name = field_name.to_s
      field = @fields.detect { |f| f.name == name }
      raise UnmappedFieldError.new("Mapping<#{@name}>: #{field_name} has not been declared as a field") if field.nil?
      field
    end

    attr_reader :signatures, :accessors, :types, :name, :fields, :target

    def initialize(repository, target, name)
      unless repository.is_a?(Clipper::Repository) && target.is_a?(Class) && name.is_a?(String)
        raise ArgumentError.new("Expected [Clipper::Repository<repository>, Class<target>, String<name>] but got #{[repository.class, target.class, name.class].inspect}")
      end

      unless Clipper::Accessors > target
        raise ArgumentError.new("Mapped class #{target.inspect} must include Clipper::Accessors")
      end

      @repository = repository
      @target = target
      @name = name

      @keys = java.util.LinkedHashSet.new
      @fields = java.util.LinkedHashSet.new

      @signatures = java.util.LinkedHashSet.new
      @accessors = java.util.LinkedHashSet.new
      @types = java.util.LinkedHashSet.new
    end

    def type_map
      @repository.class.type_map
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

      # FIXME: a field should be able to map to more than one type as in embedded values
      field = Field.new(repository_types[0], accessor, field_name.to_s, self)
      @fields << field
      field
    end

    def key(*field_names)
      raise ArgumentError.new("The key for Mapping<#{@name}> is already defined as #{@keys.inspect}") unless @keys.empty?

      missing_fields = field_names.reject { |field_name| @accessors.any? { |accessor| accessor.name == field_name } }

      unless missing_fields.empty?
        raise UnmappedFieldError.new("Mapping<#{@name}>: #{missing_fields.inspect} #{missing_fields.size > 1 ? "have" : "has"} not been delcared as #{missing_fields.size > 1 ? "fields" : "a field"}.")
      end

      @keys = field_names
    end

    def keys
      raise NoKeyError.new("No keys for Mapping<#{@name}> were defined.") if @keys.empty?
      @keys.map {|key| self[key]}
    end

    def is_key?(field)
      keys.include?(field)
    end

    private

    class UnmappedFieldError < StandardError
    end

    class NoKeyError < StandardError
    end

  end
end