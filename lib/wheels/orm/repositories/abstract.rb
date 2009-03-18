require Pathname(__FILE__).dirname + "type"

module Wheels
  module Orm
    module Repositories
      class Abstract

        include Test::Unit::Assertions

        def initialize(name, uri)
          begin
            assert_kind_of(String, name, "Repository name must be a String")
            assert_not_blank(name, "Repository name must not be blank")
            @name = name

            assert_kind_of(Wheels::Orm::Uri, uri, "Repository uri must be a Wheels::Orm::Uri")
            @uri = uri
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end
        end

        def name
          @name
        end

        def uri
          @uri
        end

        def mappings
          Wheels::Orm::Mappings[name]
        end

        def save(collection)
        end

        def create(collection)
          true
        end

        def update(collection)
        end

      end # class Abstract
    end # module Repositories
  end # module Orm
end # Wheels