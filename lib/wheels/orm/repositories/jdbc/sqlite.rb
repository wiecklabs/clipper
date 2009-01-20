require "jdbc/sqlite3"
import "org.sqlite.JDBC"

module Wheels
  module Orm
    module Repositories
      class Jdbc
        class Sqlite < Jdbc
          module Types

            @types = {}

            def self.[](field)
              (@types[field.type] || raise(UnsupportedTypeError.new(field.type))).new(field)
            end

            class String < Wheels::Orm::Repositories::Type

              def to_sql(quoting_strategy)
                "#{quoting_strategy.quote_identifier(@field.name)} varchar"
              end
            end
            @types[Wheels::Orm::Types::String] = self::String

            class Integer < Wheels::Orm::Repositories::Type

              def to_sql(quoting_strategy)
                "#{quoting_strategy.quote_identifier(@field.name)} int"
              end
            end
            @types[Wheels::Orm::Types::Integer] = self::Integer

          end # module Types
        end # class Sqlite
      end # class Jdbc
    end # module Repositories
  end # module Orm
end # module Wheels