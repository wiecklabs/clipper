module Clipper
  class Repository
    include Clipper::Types

    ##
    # Returns instance of Clipper::TypeMap for holding this repository's
    # type mappings.
    ##
    def self.type_map
      @type_map ||= create_default_map
    end

    def initialize(name, uri)
      raise ArgumentError.new("Repository name must be a String") unless name.is_a?(String)
      raise ArgumentError.new("Repository name must not be blank") if name.blank?
      @name = name

      raise ArgumentError.new("Repository uri must be a Clipper::Uri") unless uri.is_a?(Clipper::Uri)
      @uri = uri
    end

    def name
      @name
    end

    def uri
      @uri
    end

    def mappings
      @mappings ||= java.util.LinkedHashMap.new
    end

    def save(collection)
      raise NotImplementedError.new("#{self.class}#save must be implemented.")
    end

    def create(collection)
      raise NotImplementedError.new("#{self.class}#create must be implemented.")
    end

    def update(collection)
      raise NotImplementedError.new("#{self.class}#update must be implemented.")
    end

    def delete(collection)
      raise NotImplementedError.new("#{self.class}#delete must be implemented.")
    end

    def table_exists?(table_name)
      raise NotImplementedError.new("#{self.class}#table_exists? must be implemented.")
    end

    def create_table(mapping)
      raise NotImplementedError.new("#{self.class}#table_exists? must be implemented.")
    end

    def drop_table(mapping)
      raise NotImplementedError.new("#{self.class}#table_exists? must be implemented.")
    end

    def close
      raise NotImplementedError.new("#{self.class}#close must be implemented.")
    end

    private

    def self.create_default_map
      type_map = Clipper::TypeMap.new
      rep_types = const_get(:Types)

      type_map.map_type(rep_types) do |signature, types|
        signature.from [String]
        signature.to [types.string]
        signature.typecast_left lambda { |value| value.to_s }
        signature.typecast_right lambda { |value| value.to_s }
      end

      type_map.map_type(rep_types) do |signature, types|
        signature.from [Integer]
        signature.to [types.serial]
        signature.typecast_left lambda { |value| value.to_i }
        signature.typecast_right lambda { |value| value }
      end

      type_map.map_type(rep_types) do |signature, types|
        signature.from [Integer]
        signature.to [types.serial]
        signature.typecast_left lambda { |value| value.to_i }
        signature.typecast_right lambda { |value| value }
      end

      type_map.map_type(rep_types) do |signature, types|
        signature.from [Float]
        signature.to [types.float]
        signature.typecast_left lambda { |value| Float(value) }
        signature.typecast_right lambda { |value| value }
      end

      type_map.map_type(rep_types) do |signature, types|
        signature.from [Boolean]
        signature.to [types.boolean]
        signature.typecast_left lambda { |value| value }
        signature.typecast_right lambda { |value| value }
      end

      type_map
    end
  end
end