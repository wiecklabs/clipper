require Pathname(__FILE__).dirname + "type"

module Clipper
  module Repositories
    class Abstract

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
        Clipper::Mappings[name]
      end

      def save(collection)
      end

      def create(collection)
        true
      end

      def update(collection)
      end

      def close
      end

    end # class Abstract
  end # module Repositories
end