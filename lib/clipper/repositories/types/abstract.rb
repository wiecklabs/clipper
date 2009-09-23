module Clipper
  module Repositories
    module Types
      module Abstract
        class Serial
          include Clipper::Repository::Type
        end
        class Integer
          include Clipper::Repository::Type
        end
        class String
          include Clipper::Repository::Type

          def initialize(length = 255)
          end
        end
        class Float
          include Clipper::Repository::Type
        end
        class Boolean
          include Clipper::Repository::Type
        end
      end # class Sqlite
    end # class Jdbc
  end # module Repositories
end # module Clipper