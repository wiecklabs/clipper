module Beacon
  class Session

    class RepositoryMissingError < StandardError
      def initialize(name)
        super("Repository #{name.inspect} not a registered repository, can't initiate a Session")
      end
    end

    def initialize(repository_name)
      raise ArgumentError.new("Session repository_name must be a String") unless repository_name.is_a?(String)
      raise ArgumentError.new("Session repository_name must not be blank") if repository_name.blank?

      @repository = Beacon::registrations[repository_name]
      raise RepositoryMissingError.new(reponsitory_name) if @repository.nil?

      @identity_map = IdentityMap.new
    end

    def repository
      @repository
    end

    def mappings
      @repository.mappings
    end

    # def map(target, mapped_name)
    #   mapping = Beacon::Mappings::Mapping.new(target, mapped_name)
    #   yield mapping
    #   @repository.mappings << mapping
    #   mapping
    # end

    def get(target, *keys)
      mapping = @repository.mappings[target]

      conditions = Query::AndExpression.new(*mapping.keys.zip(keys).map { |condition| Query::Condition.eq(*condition) })

      query = Query.new(mapping, nil, conditions)

      @repository.select(query).first
    end

    def all(target)
      mapping = @repository.mappings[target]
      criteria = Beacon::Query::Criteria.new(mapping)

      yield(criteria) if block_given?

      @repository.select(Query.new(mapping, criteria.__options__, criteria.__conditions__))
    end

    def find(target, options, conditions)
      mapping = target.is_a?(Beacon::Mappings::Mapping) ? target : @repository.mappings[target]

      @repository.select(Query.new(mapping, options, conditions))
    end

    def save(collection)
      collection = Collection.new(mappings[collection.class], [collection]) unless collection.is_a?(Collection)
      create(collection)
    end

    def create(collection)
      @repository.create(collection)
    end

    def validate(object, context_name = 'default')
      Beacon::validate(object, context_name)
    end

    def load(object, field)
    end

  end # class Session
end # module Beacon