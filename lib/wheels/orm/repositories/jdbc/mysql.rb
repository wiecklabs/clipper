require "jdbc/mysql"

module Wheels
  module Orm
    module Repositories
      class Jdbc
        class Mysql < Jdbc

          def initialize(name, uri)
            super

            @data_source = com.mchange.v2.c3p0.ComboPooledDataSource.new
            @data_source.setJdbcUrl(uri.to_s)
            @data_source.setDriverClass("com.mysql.jdbc.Driver")
          end

          def column_definition_serial
            "INTEGER PRIMARY KEY AUTO_INCREMENT"
          end

        end # class Sqlite
      end # class Jdbc
    end # module Repositories
  end # module Orm
end # module Wheels