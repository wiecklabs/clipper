require "jdbc/hsqldb"
import "org.hsqldb.jdbcDriver"

module Wheels
  module Orm
    module Repositories
      class Jdbc
        class Hsqldb < Jdbc

          def column_definition_serial
            "IDENTITY"
          end

          def generated_keys(connection)
            statement = connection.createStatement
            result_set = statement.executeQuery("call identity()")
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