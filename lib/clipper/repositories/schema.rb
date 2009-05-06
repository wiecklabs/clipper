module Clipper
  module Repositories
    class Schema
      def initialize(repository)
        @repository = repository
      end

      def exists?(table_name)
        @repository.table_exists?(table_name)
      end

      def create(mapping)
        @repository.create_table(mapping)
      end

      def destroy(mapping)
        @repository.drop_table(mapping)
      end
    end
  end
end