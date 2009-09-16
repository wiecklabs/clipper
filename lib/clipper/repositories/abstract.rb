module Clipper
  module Repositories

    ##
    # Abstract repository class to match "abstract://" scheme.
    ##
    class Abstract < Clipper::Repository
      Types = Clipper::Repositories::Types::Abstract

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

      def table_exists?(table_name)
        true
      end

      def create_table(mapping)
        true
      end

      def drop_table(mapping)
        true
      end

      def close
        true
      end

    end # class Abstract

  end # module Repositories
end