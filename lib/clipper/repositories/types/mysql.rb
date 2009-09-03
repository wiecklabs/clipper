module Clipper
  module Repositories
    module Types
      module Mysql
        class String
          include Clipper::Repository::Type

          def initialize(length = 255)
            @col_definition = "VARCHAR(#{length})"
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
            @col_definition = 'SERIAL'
          end
        end

        class Boolean
          include Clipper::Repository::Type

          def initialize
            @col_definition = 'BOOL'
          end
        end
      end # module Mysql
    end # module Types
  end # module Repositories
end # module Clipper