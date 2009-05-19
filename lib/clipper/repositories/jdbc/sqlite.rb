require "jdbc/sqlite3"
import "org.sqlite.JDBC"

module Clipper
  module Repositories
    class Jdbc
      class Sqlite < Jdbc

        def initialize(name, uri)
          super

          @data_source = com.mchange.v2.c3p0.DataSources.unpooledDataSource(uri.to_s)
        end
        
        # SQLite3 doesn't have a boolean type: http://www.sqlite.org/datatype3.html
        def column_definition_boolean(field)
          "INTEGER"
        end

        # If you define an auto-increment field in Sqlite3, it has to also be the primary key
        def column_definition_serial(field)
          "INTEGER PRIMARY KEY AUTOINCREMENT"
        end

        protected

        def key_definition(mapping)
          # If we've already declared a serial column, don't worry about the key definition
          return nil if mapping.keys.any? { |field| field.type.is_a?(Clipper::Types::Serial) }

          "PRIMARY KEY (#{mapping.keys.map { |field| quote_identifier(field.name) }.join(', ')})"
        end

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
end # module Clipper