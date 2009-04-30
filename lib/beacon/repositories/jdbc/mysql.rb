require "jdbc/mysql"
import "com.mysql.jdbc.Driver"

module Beacon
  module Repositories
    class Jdbc
      class Mysql < Jdbc

        def initialize(name, uri)
          super

          @data_source = com.mchange.v2.c3p0.ComboPooledDataSource.new
          @data_source.setJdbcUrl(uri.to_s)
        end

      end # class Sqlite
    end # class Jdbc
  end # module Repositories
end # module Beacon