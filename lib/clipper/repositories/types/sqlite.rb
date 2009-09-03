module Clipper
  module Repositories
    module Types
      module Sqlite
        class String
          include Clipper::Repository::Type

          def initialize(length = 255)
            @col_definition = "TEXT"
          end
        end

        class Integer
          include Clipper::Repository::Type

          def initialize
            @col_definition = 'INTEGER'
          end
        end

        class Float
          include Clipper::Repository::Type

          def initialize
            @col_definition = 'FLOAT'
          end
        end

        class Serial
          include Clipper::Repository::Type

          def initialize
            @col_definition = 'INTEGER PRIMARY KEY AUTOINCREMENT'
          end
        end

        # SQLite3 doesn't have a boolean type: http://www.sqlite.org/datatype3.html
        class Boolean
          include Clipper::Repository::Type

          def initialize
            @col_definition = 'INTEGER'
          end
        end
      end # class Sqlite
    end # class Jdbc
  end # module Repositories
end # module Clipper