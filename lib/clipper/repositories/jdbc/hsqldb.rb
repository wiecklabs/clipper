require "jdbc/hsqldb"
import "org.hsqldb.jdbcDriver"

module Clipper
  module Repositories
    class Jdbc
      class Hsqldb < Jdbc

        Types = Clipper::Repositories::Types::Hsqldb

        def initialize(name, uri)
          super

          @data_source = com.mchange.v2.c3p0.DataSources.unpooledDataSource(uri.to_s)
        end

        def generated_keys(connection)
          statement = connection.createStatement
          result_set = statement.executeQuery("call identity()")
          metadata = result_set.getMetaData

          key = nil

          if result_set.next
            key = result_set.getObject(1)
          end

          result_set.close
          statement.close

          key
        end

      end # class Hsqldb
    end # class Jdbc
  end # module Repositories
end # module Clipper