require "jdbc/mysql"
import "com.mysql.jdbc.Driver"

module Clipper
  module Repositories
    class Jdbc
      class Mysql < Jdbc
        Types = Clipper::Repositories::Types::Mysql

        def initialize(name, uri)
          super

          @data_source = com.mchange.v2.c3p0.ComboPooledDataSource.new
          @data_source.setJdbcUrl(uri.to_s)
        end

      end # class Mysql
    end # class Jdbc
  end # module Repositories
end # module Clipper