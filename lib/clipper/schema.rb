module Clipper
  class Schema
    def initialize(repository)
      @repository = Clipper::registrations[repository]
    end

    def create(mapped_class)
      mapping = @repository.mappings[mapped_class]
      mapping.associations.each do |association|
        next unless association.is_a?(Clipper::Mappings::ManyToMany)
        @repository.schema.create(association.target_mapping)
      end
      @repository.schema.create(mapping)
    end

    def exists?(mapped_class)
      mapping = @repository.mappings[mapped_class]
      @repository.schema.exists?(mapping.name)
    end

    def destroy(mapped_class)
      mapping = @repository.mappings[mapped_class]
      mapping.associations.each do |association|
        next unless association.is_a?(Clipper::Mappings::ManyToMany)
        @repository.schema.destroy(association.target_mapping)
      end
      @repository.schema.destroy(mapping)
    end
  end
end