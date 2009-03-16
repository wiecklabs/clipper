module Wheels
  module Orm
    class Session

      include Test::Unit::Assertions

      def initialize(repository_name)
        begin
          assert_kind_of(String, repository_name, "Session repository_name must be a String")
          assert_not_blank(repository_name, "Session repository_name must not be blank")
          @repository = Wheels::Orm::Repositories::registrations[repository_name]
          assert_not_nil(@repository, "Repository #{@repository.inspect} not a registered repository, can't initiate a Session")
        rescue Test::Unit::AssertionFailedError => e
          raise ArgumentError.new(e.message)
        end

        @identity_map = IdentityMap.new
      end

      def repository
        @repository
      end

      def mappings
        @repository.mappings
      end

      def map(target, mapped_name)
        mapping = Wheels::Orm::Mappings::Mapping.new(target, mapped_name)
        yield mapping
        @repository.mappings << mapping
        mapping
      end

      def get(target, *keys)
        mapping = @repository.mappings[target]

        conditions = Query::AndExpression.new(*mapping.keys.zip(keys).map { |condition| Query::Condition.eq(*condition) })

        query = Query.new(mapping, conditions)

        @repository.select(query).first
      end

      def all(target, options = nil)
        raise ArgumentError.new("Wheels::Orm::Session#all requires a block") unless block_given?
        
        mapping = @repository.mappings[target]
        criteria = Wheels::Orm::Query::Criteria.new(mapping)
        yield(criteria)

        @repository.select(Query.new(mapping, criteria.condition))
      end
      
      def find(target, conditions = nil)
        mapping = @repository.mappings[target]

        @repository.select(Query.new(mapping, conditions))
      end

      def save(collection)
        collection = Collection.new(mappings[collection.class], [collection]) unless collection.is_a?(Collection)
        create(collection)
      end

      def create(collection)
        @repository.create(collection)
      end

      def validate(object, context_name = 'default')
        mapping = @repository.mappings[object.class]
        mapping.validate(object, context_name)
        # context = mapping.validation_contexts(context_name)
        # context.validate(target)
      end

      def load(object, field)
      end

    end # class Session
  end # module Orm
end # module Wheels