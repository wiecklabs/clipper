require "jdbc/mysql"
import "com.mysql.jdbc.Driver"

module Wheels
  module Orm
    module Repositories
      class Jdbc
        class Mysql < Jdbc

          def column_definition_serial
            "INTEGER PRIMARY KEY AUTO_INCREMENT"
          end

        end # class Sqlite
      end # class Jdbc
    end # module Repositories
  end # module Orm
end # module Wheels