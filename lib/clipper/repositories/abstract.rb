require Pathname(__FILE__).dirname + "type"

module Clipper
  module Repositories

    ##
    # Abstract repository class to match "abstract://" scheme.
    ##
    class Abstract < Clipper::Repository

      def save(collection)
        true
      end

      def create(collection)
        true
      end

      def update(collection)
        true
      end

      def delete(collection)
        true
      end

      def close
        true
      end

    end # class Abstract

  end # module Repositories
end