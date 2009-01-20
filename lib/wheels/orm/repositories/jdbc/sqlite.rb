require "jdbc/sqlite3"
import "org.sqlite.JDBC"

module Wheels
  module Orm
    module Repositories
      class Jdbc
        class Sqlite < Jdbc

          def generated_keys(connection)
            statement = connection.createStatement
            result_set = statement.executeQuery("select last_insert_rowid()")
            metadata = result_set.getMetaData

            keys = nil

            if result_set.next
              key = result_set.getObject(1)
            end

            result_set.close
            statement.close

            key == 0 ? nil : key
          end

        end # class Sqlite
      end # class Jdbc
    end # module Repositories
  end # module Orm
end # module Wheels