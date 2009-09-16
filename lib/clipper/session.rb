module Clipper

  class Session

    class RepositoryMissingError < StandardError
      def initialize(repository_name)
        super("Repository #{repository_name.inspect} not a registered repository, can't initiate a Session")
      end
    end

    def initialize(repository_name, immediate_flush = false)
      raise ArgumentError.new("Session repository_name must be a String") unless repository_name.is_a?(String)
      raise ArgumentError.new("Session repository_name must not be blank") if repository_name.blank?

      @repository_name = repository_name
      @identity_map = IdentityMap.new
      @immediate_flush = immediate_flush
      @unit_of_work = UnitOfWork.new(self, immediate_flush)
    end

    def unit_of_work
      @unit_of_work
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

    def enlist(object)
      @unit_of_work.register(object)

      self
    end
    alias << enlist
    alias save enlist

    def delete(object)
      @unit_of_work.register_deletion(object)

      self
    end
    alias - delete

    def flush
      @unit_of_work.execute
    end

    def mappings
      repository.mappings
    end

    def map(target, mapped_name, &b)
      mappings[target] = Clipper::Mapping.map(repository, target, mapped_name, &b)
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
      mapping = target.is_a?(Clipper::Mapping) ? target : repository.mappings[target]

      map_results(repository.select(Query.new(mapping, options, conditions), self))
    end

    def key(instance)
      mapping = repository.mappings[instance.class]
      mapping.keys.map do |field|
        field.accessor.get(instance)
      end
    end

    def validate(object, context_name = 'default')
      object.validate(context_name)
    end

    def load(object, field)
    end

    def stored?(instance)
      instance.__session__ &&
        instance.__session__.repository == repository &&
        instance.__session__.identity_map.include?(instance)
    end

    def map_type(&b)
      # TODO: Better way of doing this?
      repository.class.type_map.map_type(repository.class::Types, &b)
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