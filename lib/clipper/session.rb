module Clipper
  class Session

    class RepositoryMissingError < StandardError
      def initialize(repository_name)
        super("Repository #{repository_name.inspect} not a registered repository, can't initiate a Session")
      end
    end

    def initialize(repository_name)
      raise ArgumentError.new("Session repository_name must be a String") unless repository_name.is_a?(String)
      raise ArgumentError.new("Session repository_name must not be blank") if repository_name.blank?

      @repository_name = repository_name
      @identity_map = IdentityMap.new
    end

    def repository
      @repository ||= begin
        if repository = Clipper::registrations[@repository_name]
          repository
        else
          raise RepositoryMissingError.new(@repository_name)
        end
      end
    end

    def identity_map
      @identity_map
    end

    def mappings
      repository.mappings
    end

    def map(target, mapped_name, &b)
      Clipper::Mappings[@repository_name].map(target, mapped_name, &b)
    end

    def get(target, *keys)
      mapping = repository.mappings[target]

      conditions = Query::AndExpression.new(*mapping.keys.zip(keys).map { |condition| Query::Condition.eq(*condition) })

      query = Query.new(mapping, nil, conditions)

      map_results([repository.select(query, self).first]).first
    end

    def all(target)
      mapping = repository.mappings[target]
      criteria = Clipper::Query::Criteria.new(mapping)

      yield(criteria) if block_given?

      map_results(repository.select(Query.new(mapping, criteria.__options__, criteria.__conditions__), self))
    end

    def find(target, options, conditions)
      mapping = target.is_a?(Clipper::Mappings::Mapping) ? target : repository.mappings[target]

      map_results(repository.select(Query.new(mapping, options, conditions), self))
    end

    def key(instance)
      mapping = repository.mappings[instance.class]
      mapping.keys.map do |field|
        field.get(instance)
      end
    end

    def save(collection)
      collection = Collection.new(mappings[collection.class], [collection].flatten) unless collection.is_a?(Collection)

      result = repository.save(collection, self)
      result
    end

    def validate(object, context_name = 'default')
      Clipper::validate(object, context_name)
    end

    def load(object, field)
    end

    def stored?(instance)
      instance.__session__ &&
        instance.__session__.repository == repository &&
        instance.__session__.identity_map.include?(instance)
    end

    private

    def map_results(results)
      results.each do |result|
        result.instance_variable_set("@__session__", self)
        self.identity_map.add(result)
      end

      results
    end

  end # class Session
end # module Clipper