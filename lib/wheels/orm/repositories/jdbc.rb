module Wheels
  module Orm
    module Repositories
      class Jdbc < Abstract
        autoload :Sqlite, (Pathname(__FILE__).dirname + "jdbc" + "sqlite.rb").to_s

        def with_connection
          connection = nil
          begin
            connection = java.sql.DriverManager.getConnection(@uri.to_s)
            return yield(connection) if block_given?
          ensure
            connection.close if connection
          end
        end

        def create_table(mapping)
          sql = <<-EOS.compress_lines
          CREATE TABLE #{quote_identifier(mapping.name)} (#{mapping.fields.map { |field| column_definition(field) }.join(", ") });
          EOS

          with_connection do |connection|
            stmt = connection.prepareStatement(sql)
            stmt.execute
            stmt.close
          end

          nil
        end

        def drop_table(mapping)
          sql = <<-EOS.compress_lines
          DROP TABLE #{quote_identifier(mapping.name)};
          EOS

          with_connection do |connection|
            stmt = connection.prepareStatement(sql)
            stmt.execute
            stmt.close
          end

          nil
        end

        def table_exists?(table_name)
          with_connection do |connection|
            metadata = connection.getMetaData()
            table = metadata.getTables("", "", table_name, ["TABLE"].to_java(:String))
            !!table.next
          end
        end

        def schema
          @schema ||= Wheels::Orm::Repositories::Schema.new(self)
        end

        ##
        # Quotes the table or column name according the connection's declared
        # quote string.
        #
        def quote_identifier(identifier)
          identifier.gsub(/([^\.]+)/, "#{self.quote_string}\\1#{self.quote_string}")
        end

        protected

        ##
        # Retrieve the string user for quoting table and column names for this
        # connection. Default to '"' if the string returned by the connection
        # does not specify a character.
        #
        def quote_string
          @quote_string ||= with_connection { |connection| connection.getMetaData.getIdentifierQuoteString }
          @quote_string = '"' if @quote_string == " "
          @quote_string
        end

        def column_definition(field)
          column_name = quote_identifier(field.name)
          case field.type
          when Wheels::Orm::Types::Integer
            "#{column_name} INTEGER"
          when Wheels::Orm::Types::String
            "#{column_name} VARCHAR"
          when Wheels::Orm::Types::Serial
            "#{column_name} INTEGER PRIMARY KEY AUTOINCREMENT"
          else
            raise Wheels::Orm::UnsupportedTypeError.new(field.type)
          end
        end

      end
    end
  end
end