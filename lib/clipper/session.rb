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

    def save(instance)
      collection = instance.is_a?(Collection) ? instance : Collection.new(mappings[instance.class], [instance].flatten)

      save_cascade(collection)
    end

    def save_cascade(collection, visited = [])
      return if visited.include?(collection)

      collection = collection.is_a?(Collection) ? collection : Collection.new(mappings[collection.class], [collection].flatten)

      repository.save(collection, self)

      visited << collection
      collection.each do |item|
        visited << self.key(item)
      end

      collection.mapping.associations.each do |association|
        case association
        when Mappings::BelongsTo then
          collection.each do |item|
            data = association.get(item)
            return if data.nil?
            return if visited.include?(self.key(data))

            if data
              save_cascade(data, visited)
              association.set_key(item, data)
              
              # This should really only be called if the item was new to begin with
              save(item)
            end
          end
        when Mappings::HasMany then
          collection.each do |item|
            data = association.get(item)
            next if visited.include?(data)

            data.each do |associated_item|
              association.set_key(item, associated_item)
            end

            save_cascade(data, visited)
          end
        end
      end

      collection
    end

    def delete(collection)
      collection = Collection.new(mappings[collection.class], [collection].flatten) unless collection.is_a?(Collection)

      result = repository.delete(collection, self)
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