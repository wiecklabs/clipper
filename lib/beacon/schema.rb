module Beacon
  class Schema
    def initialize(repository)
      @repository = Beacon::Repositories.registrations[repository]
    end

    def create(mapped_class)
      mapping = @repository.mappings[mapped_class]
      @repository.schema.create(mapping)
    end

    def exists?(mapped_class)
      mapping = @repository.mappings[mapped_class]
      @repository.schema.exists?(mapping.name)
    end

    def destroy(mapped_class)
      mapping = @repository.mappings[mapped_class]
      @repository.schema.destroy(mapping)
    end
  end
end