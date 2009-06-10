require Pathname(__FILE__).dirname.parent.parent + "vendor" + "c3p0-0.9.1.2.jar"

module Clipper
  module Repositories
    class Jdbc < Abstract

      import 'org.apache.log4j.Logger'
      import 'java.sql.Types'

      autoload :Sqlite, (Pathname(__FILE__).dirname + "jdbc" + "sqlite.rb").to_s
      autoload :Hsqldb, (Pathname(__FILE__).dirname + "jdbc" + "hsqldb.rb").to_s
      autoload :Mysql, (Pathname(__FILE__).dirname + "jdbc" + "mysql.rb").to_s

      attr_accessor :logger

      def initialize(name, uri)
        @logger = Logger.getLogger(self.class.name)
        super
      end

      def with_connection
        connection = nil
        begin
          connection = @data_source.getConnection
          return yield(connection) if block_given?
        ensure
          connection.close if connection
        end
      end

      def syntax
        @syntax ||= Clipper::Syntax::Sql.new(self)
      end

      def select(query, session)
        mapping_fields = query.mapping.fields

        statement = "SELECT #{mapping_fields.map { |field| quote_identifier("#{field.mapping.name}.#{field.name}") } * ", "}"
        statement << "FROM #{quote_identifier(query.mapping.name)}"
        statement << " WHERE #{syntax.serialize(query.conditions)}" if query.conditions

        if query.order
          statement << " ORDER BY "
          statement << query.order.map do |field, direction|
            field_name = quote_identifier("#{field.mapping.name}.#{field.name}")
            direction == :desc ? field_name + " DESC" : field_name
          end.join(", ")
        end

        statement << " LIMIT #{query.limit}" if query.limit
        statement << " OFFSET #{query.offset}" if query.offset

        collection = Clipper::Collection.new(query.mapping, [])

        with_connection do |connection|
          if query.paramaters.empty?
            logger.debug(statement)

            stmt = connection.createStatement
            results = stmt.executeQuery(statement)
          else
            logger.debug(statement + " -> #{query.paramaters.inspect}")

            stmt = connection.prepareStatement(statement)

            query.fields.zip(query.paramaters).each_with_index do |attribute, index|
              bind_value_to_statement(stmt, index + 1, *attribute)
            end

            results = stmt.executeQuery
          end

          results_metadata = results.getMetaData

          while results.next
            resource = query.mapping.target.allocate
            values = (1..results_metadata.getColumnCount).zip(mapping_fields).map do |i, field|
              get_value_from_result_set(results, i, field.type)
            end

            mapping_fields.zip(values) { |field, value| field.value(resource).set!(value) }
            collection << resource
          end

          results.close
          stmt.close

        end

        collection
      end

      def get_value_from_result_set(results, index, type)
        case type
        when Clipper::Types::Time
          t = results.getTime(index)
          Time.local(t.seconds, t.minutes, t.hours, *Time.now.to_a[3..-1])
        when Clipper::Types::Date
          d = results.getDate(index)
          Date.new(d.year + 1900, d.month + 1, d.date)
        when Clipper::Types::DateTime
          t = results.getTimestamp(index)
          Time.at(*t.getTime.divmod(1000)).send(:to_datetime)
        when Clipper::Types::Boolean
          results.getBoolean(index)
        else
          results.getObject(index)
        end
      end

      def create(collection, session)
        with_connection do |connection|
          metadata = connection.getMetaData

          mapping = collection.mapping
          serial_key = mapping.keys.detect { |field| field.type.is_a?(Clipper::Types::Serial) }

          collection.each do |object|

            values = mapping.fields.map { |field| field.value(object) }.select { |value| value.dirty? }

            statement = "INSERT INTO #{quote_identifier(collection.mapping.name)} "
            statement << "(" + values.map { |value| quote_identifier(value.field.name) } * ", "
            statement << ") VALUES ("
            statement << (['?'] * values.size) * ", "
            statement << ")"

            stmt = connection.prepareStatement(statement)

            result = nil

            logger.debug(statement + " -> #{values.map { |value| value.get }.inspect}")

            values.each_with_index do |value, index|
              bind_value_to_statement(stmt, index + 1, value.field, value.get)
            end

            stmt.execute

            result = metadata.supportsGetGeneratedKeys ? generated_keys(connection, stmt) : generated_keys(connection)

            serial_key.value(object).set!(result) if serial_key && result
            values.each { |value| value.set_original_value! }

            session.identity_map.add(object)
            stmt.close
          end
        end
      end

      # def create(collection, session)
      #   with_connection do |connection|
      #     metadata = connection.getMetaData
      #     supports_generated_keys = metadata.supportsGetGeneratedKeys
      # 
      #     mapping = collection.mapping
      # 
      #     fields = mapping.fields
      #     serial_key = mapping.keys.detect { |field| field.type.is_a?(Clipper::Types::Serial) }
      # 
      #     statement = "INSERT INTO #{quote_identifier(collection.mapping.name)} ("
      #     statement << fields.map { |field| quote_identifier(field.name) } * ", "
      #     statement << ") VALUES ("
      #     statement << (['?'] * fields.size) * ", "
      #     statement << ")"
      # 
      #     if supports_generated_keys
      #       stmt = serial_key ? connection.prepareStatement(statement, 1) : connection.prepareStatement(statement)
      #     end
      # 
      #     collection.each do |object|
      #       unless supports_generated_keys
      #         stmt = connection.prepareStatement(statement)
      #       end
      # 
      #       result = nil
      # 
      #       attributes = fields.map { |field| [field, field.get(object)] }
      # 
      #       logger.debug(statement + " -> #{attributes.transpose[1].inspect}")
      # 
      #       attributes.each_with_index do |attribute, index|
      #         bind_value_to_statement(stmt, index + 1, *attribute)
      #       end
      # 
      #       if supports_generated_keys
      #         stmt.addBatch
      #       else
      #         stmt.execute
      #         stmt.close
      # 
      #         result = generated_keys(connection)
      # 
      #         serial_key.value(object).set!(result) if serial_key && result
      # 
      #         session.identity_map.add(object)
      #       end
      # 
      #       attributes.each { |field,| field.value(object).set_original_value! }
      # 
      #       # HACK: Find a better way to do this
      #       # object.instance_variable_set("@__session__", session)
      #     end
      # 
      #     if supports_generated_keys
      #       stmt.executeBatch
      # 
      #       if serial_key
      #         keys = generated_keys(connection, stmt)
      # 
      #         collection.zip(keys) do |object, value|
      #           serial_key.value(object).set!(value)
      #           session.identity_map.add(object)
      #         end
      #       end
      # 
      #       stmt.close
      #     end
      #   end
      # end

      def update(collection, session)
        with_connection do |connection|
          metadata = connection.getMetaData
          supports_generated_keys = metadata.supportsGetGeneratedKeys

          mapping = collection.mapping

          fields = mapping.fields
          key_fields = mapping.keys

          statement = "UPDATE #{quote_identifier(collection.mapping.name)} SET "
          statement << fields.map { |field| quote_identifier(field.name) + " = ?"}.join(', ')
          statement << " WHERE ("
          statement << key_fields.map { |field| quote_identifier(field.name) + " = ?"}.join(' AND ') 
          statement << ")"

          stmt = connection.prepareStatement(statement)

          collection.each do |object|
            result = nil

            attributes = fields.map { |field| [field, field.get(object)] } + key_fields.map { |key_field| [key_field, key_field.get(object)] }

            logger.debug(statement + " -> #{attributes.transpose[1].inspect}")

            attributes.each_with_index do |attribute, index|
              bind_value_to_statement(stmt, index + 1, *attribute)
            end

            stmt.execute
            stmt.close

            fields.each { |field| field.value(object).set_original_value! }
          end
        end
      end

      def delete(collection, session)
        with_connection do |connection|
          metadata = connection.getMetaData
          supports_generated_keys = metadata.supportsGetGeneratedKeys

          mapping = collection.mapping

          fields = mapping.fields
          key_fields = mapping.keys

          statement = "DELETE FROM #{quote_identifier(collection.mapping.name)} "
          statement << " WHERE ("
          statement << key_fields.map { |field| quote_identifier(field.name) + " = ?"}.join(' AND ') 
          statement << ")"

          stmt = connection.prepareStatement(statement)

          collection.each do |object|
            result = nil

            attributes = key_fields.map { |key_field| [key_field, key_field.get(object)] }

            attributes.each_with_index do |attribute, index|
              bind_value_to_statement(stmt, index + 1, *attribute)
            end

            stmt.execute
            stmt.close

            # TODO: This smells, but works for now
            session.identity_map.remove(object)
            object.__session__.identity_map.remove(object)
          end
        end
      end

      def create_table(mapping)
        components = [
          mapping.fields.map { |field| column_definition(field) }.join(", "),
          key_definition(mapping)
        ].compact

        sql = <<-EOS.compress_lines
        CREATE TABLE #{quote_identifier(mapping.name)} (#{components.join(',')});
        EOS

        logger.debug(sql)

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

        logger.debug(sql)

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
          table = metadata.getTables(nil, nil, table_name, ["TABLE"].to_java(:String))
          !!table.next
        end
      end

      def schema
        @schema ||= Clipper::Repositories::Schema.new(self)
      end

      ##
      # Quotes the table or column name according the connection's declared
      # quote string.
      #
      def quote_identifier(identifier)
        quote_string = self.quote_string
        identifier.gsub(/([^\.]+)/, "#{quote_string}\\1#{quote_string}")
      end

      protected

      ##
      # Retrieve the string user for quoting table and column names for this
      # connection. Default to '"' if the string returned by the connection
      # does not specify a character.
      #
      def quote_string
        @quote_string ||= begin
          quote_string = with_connection { |connection| connection.getMetaData.getIdentifierQuoteString }
          quote_string == " " ? '"' : quote_string
        end
      end

      def key_definition(mapping)
        return nil unless mapping.keys.any?

        "CONSTRAINT #{quote_identifier(mapping.name + '_pkey')} PRIMARY KEY (#{mapping.keys.map { |field| quote_identifier(field.name) }.join(', ')})"
      end

      def column_definition(field)
        column_name = quote_identifier(field.name)
        case field.type
        when Clipper::Types::Integer
          "#{column_name} INTEGER"
        when Clipper::Types::Serial
          "#{column_name} #{column_definition_serial(field)}"
        when Clipper::Types::Float
          "#{column_name} #{column_definition_float(field)}"
        when Clipper::Types::String
          "#{column_name} #{column_definition_string(field)}"
        when Clipper::Types::Text
          "#{column_name} #{column_definition_text(field)}"
        when Clipper::Types::DateTime
          "#{column_name} TIMESTAMP"
        when Clipper::Types::Date
          "#{column_name} DATE"
        when Clipper::Types::Time
          "#{column_name} TIME"
        when Clipper::Types::Boolean
          "#{column_name} #{column_definition_boolean(field)}"
        else
          raise Clipper::UnsupportedTypeError.new(field.type)
        end
      end

      def column_definition_float(field)
        "FLOAT(#{field.type.scale}, #{field.type.precision})"
      end

      def column_definition_serial(field)
        "INTEGER AUTO_INCREMENT"
      end

      def column_definition_string(field)
        "VARCHAR(#{field.type.size})"
      end

      def column_definition_text(field)
        "TEXT"
      end
      
      def column_definition_boolean(field)
        "BOOL"
      end

      def bind_value_to_statement(statement, index, field, value)
        if value.nil?
          statement.setNull(index, 4)
        else
          case field.type
          when Clipper::Types::Integer
            statement.setInt(index, value)
          when Clipper::Types::Serial
            statement.setInt(index, value)
          when Clipper::Types::String
            statement.setString(index, value)
          when Clipper::Types::Text
            statement.setString(index, value)
          when Clipper::Types::Float
            statement.setString(index, value.to_s)
          when Clipper::Types::Boolean
            statement.setBoolean(index, value)
          when Clipper::Types::Time
            statement.setTime(index, java.sql.Time.new(value.to_f * 1000))
          when Clipper::Types::Date
            statement.setDate(index, java.sql.Date.new(Time.local(value.year, value.month, value.day).to_f * 1000))
          when Clipper::Types::DateTime
            case value
            when Time
              time = value.utc
            else
              d = value.new_offset
              time = Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec, d.sec_fraction * 86400000000)
            end

            statement.setTimestamp(index, java.sql.Timestamp.new(time.to_f * 1000))
          else
            raise Clipper::UnsupportedTypeError.new(field.type)
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
          key = result_set.getObject(1)
        end

        result_set.close

        key
      end

    end
  end
end