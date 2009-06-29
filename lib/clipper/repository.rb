module Clipper
  class Repository

    ##
    # Returns instance of Clipper::TypeMap for holding this repository's
    # type mappings.
    ##
    def self.type_map
      @type_map ||= Clipper::TypeMap.new
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

    def close
      raise NotImplementedError.new("#{self.class}#close must be implemented.")
    end
  end
end