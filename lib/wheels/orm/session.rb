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

      def map(target, mapped_name)
        mapping = Wheels::Orm::Mappings::Mapping.new(target, mapped_name)
        yield mapping
        @repository.mappings[target] = mapping
      end

      def save(collection)
        collection = Collection.new([collection]) unless collection.is_a?(Collection)
        create(collection)
      end

      def create(collection)
        @repository.create(collection)
      end

    end # class Session
  end # module Orm
end # module Wheels