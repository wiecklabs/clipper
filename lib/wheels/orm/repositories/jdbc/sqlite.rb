require "jdbc/sqlite3"
import "org.sqlite.JDBC"

module Wheels
  module Orm
    module Repositories
      class Jdbc
        class Sqlite < Jdbc
        end # class Sqlite
      end # class Jdbc
    end # module Repositories
  end # module Orm
end # module Wheels