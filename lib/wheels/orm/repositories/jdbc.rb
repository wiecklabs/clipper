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

        def create(collection)
          collection.each do |object|
            mapping = mappings[object.class]

            attributes = mapping.fields.map { |field| [field, field.get(object)] }

            statement = "INSERT INTO #{quote_identifier(mapping.name)} ("
            statement << attributes.map { |field,| quote_identifier(field.name) } * ", "
            statement << ") VALUES ("
            statement << (['?'] * attributes.size) * ", "
            statement << ")"

            result = nil
            with_connection do |connection|
              metadata = connection.getMetaData

              if metadata.supportsGetGeneratedKeys
                stmt = connection.prepareStatement(statement, 1)
              else
                stmt = connection.prepareStatement(statement)
              end

              attributes.each_with_index do |attribute, index|
                field, value = attribute
                bind_value_to_statement(stmt, index + 1, field, value)
              end

              stmt.execute

              if metadata.supportsGetGeneratedKeys
                result = generated_keys(connection, stmt)
              else
                result = generated_keys(connection)
              end

              mapping.keys.first.set(object, result) if result

              stmt.close

            end

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

        def bind_value_to_statement(statement, index, field, value)
          if value.nil?
            column = statement.getConnection.getMetaData.getColumns("", "", field.mapping.name, field.name)
            column.next
            type = column.getInt("DATA_TYPE")
            column.close

            statement.setNull(index, type)
          else
            case field.type
            when Wheels::Orm::Types::Integer
              statement.setInt(index, value)
            when Wheels::Orm::Types::String
              statement.setString(index, value)
            when Wheels::Orm::Types::Serial
              statement.setInt(index, value)
            else
              raise Wheels::Orm::UnsupportedTypeError.new(field.type)
            end
          end
        end

        ##
        # Returns the generated keys for database drivers which support returning
        # the keys through the JDBC (DatabaseMetaData.supportsGetGeneratedKeys).
        # 
        # Drivers which do not support this (like Sqlite) overwrite this function
        # to run a query to retrieve the key.
        # 
        def generated_keys(connection, statement = nil)

          return nil unless statement

          result_set = statement.getGeneratedKeys
          metadata = result_set.getMetaData
          key = nil

          if result_set.next
            key = result_set.getObject(1)
          end

          result_set.close

          key == 0 ? nil : key
        end

      end
    end
  end
end