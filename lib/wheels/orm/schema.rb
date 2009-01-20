module Wheels
  module Orm
    class Schema
      def initialize(repository)
        @repository = Wheels::Orm::Repositories.registrations[repository]
      end

      def create(mapping_class)
        mapping = @repository.mappings[mapping_class]
        @repository.schema.create(mapping)
      end

      def exists?(mapping_class)
        mapping = @repository.mappings[mapping_class]
        @repository.schema.exists?(mapping.name)
      end

      def destroy(mapping_class)
        mapping = @repository.mappings[mapping_class]
        @repository.schema.destroy(mapping)
      end
    end
  end
end