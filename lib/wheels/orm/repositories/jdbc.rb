module Wheels
  module Orm
    module Repositories
      class Jdbc < Abstract
        autoload :Sqlite, (Pathname(__FILE__).dirname + "jdbc" + "sqlite.rb").to_s
        autoload :Hsqldb, (Pathname(__FILE__).dirname + "jdbc" + "hsqldb.rb").to_s
        autoload :Mysql, (Pathname(__FILE__).dirname + "jdbc" + "mysql.rb").to_s

        def initialize(*args)
          super
        end

        def with_connection
          connection = nil
          begin
            connection = java.sql.DriverManager.getConnection(@uri.to_s)
            return yield(connection) if block_given?
          ensure
            connection.close if connection
          end
        end

        def syntax
          @syntax ||= Wheels::Orm::Syntax::Sql.new(self)
        end

        def select(query)
          statement = "SELECT #{query.mapping.fields.map { |field| quote_identifier("#{field.mapping.name}.#{field.name}") } * ", "} "
          statement << "FROM #{quote_identifier(query.mapping.name)} "
          statement << "WHERE #{syntax.serialize(query.conditions)}" if query.conditions

          collection = Wheels::Orm::Collection.new(query.mapping, [])

          with_connection do |connection|
            metadata = connection.getMetaData

            if query.paramaters.empty?
              stmt = connection.createStatement
              results = stmt.executeQuery(statement)
            else
              stmt = connection.prepareStatement(statement)

              query.fields.zip(query.paramaters).each_with_index do |attribute, index|
                bind_value_to_statement(stmt, index + 1, *attribute)
              end

              results = stmt.executeQuery
            end

            results_metadata = results.getMetaData

            while results.next
              resource = query.mapping.target.new
              values = (1..results_metadata.getColumnCount).map { |i| results.getObject(i) }
              query.mapping.fields.zip(values) { |field, value| field.set(resource, value) }
              collection << resource
            end

            results.close
            stmt.close

          end

          collection
        end

        def create(collection)
          with_connection do |connection|
            metadata = connection.getMetaData
            supports_generated_keys = metadata.supportsGetGeneratedKeys

            mapping = collection.mapping

            fields = mapping.fields

            statement = "INSERT INTO #{quote_identifier(collection.mapping.name)} ("
            statement << fields.map { |field| quote_identifier(field.name) } * ", "
            statement << ") VALUES ("
            statement << (['?'] * fields.size) * ", "
            statement << ")"

            if supports_generated_keys
              stmt = connection.prepareStatement(statement, 1)
            end

            collection.each do |object|
              unless supports_generated_keys
                stmt = connection.prepareStatement(statement)
              end

              result = nil

              fields.map { |field| [field, field.get(object)] }.each_with_index do |attribute, index|
                bind_value_to_statement(stmt, index + 1, *attribute)
              end

              if supports_generated_keys
                stmt.addBatch
              else
                stmt.execute
                stmt.close

                result = generated_keys(connection)

                mapping.keys.first.set(object, result) if result
              end

            end

            if supports_generated_keys
              stmt.executeBatch

              keys = generated_keys(connection, stmt)
              key = mapping.keys.first

              collection.zip(keys) { |object, value| key.set(object, value) }

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
          when Wheels::Orm::Types::Serial
            "#{column_name} #{column_definition_serial}"
          when Wheels::Orm::Types::Float
            "#{column_name} #{column_definition_float}"
          when Wheels::Orm::Types::String
            "#{column_name} VARCHAR(255)"
          else
            raise Wheels::Orm::UnsupportedTypeError.new(field.type)
          end
        end

        def column_definition_float
          "FLOAT(7,2)"
        end

        def column_definition_serial
          "INTEGER PRIMARY KEY AUTO_INCREMENT"
        end

        def bind_value_to_statement(statement, index, field, value)
          if value.nil?
            statement.setNull(index, 4)
          else
            case field.type
            when Wheels::Orm::Types::Integer
              statement.setInt(index, value)
            when Wheels::Orm::Types::Serial
              statement.setInt(index, value)
            when Wheels::Orm::Types::String
              statement.setString(index, value)
            when Wheels::Orm::Types::Float
              statement.setString(index, value.to_s)
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

          keys = []

          while result_set.next
            keys << result_set.getObject(1)
          end

          result_set.close

          keys
        end

      end
    end
  end
end