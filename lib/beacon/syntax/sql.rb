module Beacon
  module Syntax
    class Sql

      def initialize(repository)
        @repository = repository
      end

      def serialize(sexp)
        send(*sexp)
      end

      protected

      def and(*args)
        "(" + args.map do |expr|
          send(*expr)
        end.join(" AND ") + ")"
      end

      def or(*args)
        "(" + args.map do |expr|
          send(*expr)
        end.join(" OR ") + ")"
      end

      def gt(field, value)
        "#{normalize_field(field)} > #{normalize_value(value)}"
      end

      def lt(field, value)
        "#{normalize_field(field)} < #{normalize_value(value)}"
      end

      def eq(field, value)
        "#{normalize_field(field)} = #{normalize_value(value)}"
      end

      private

      def normalize_field(field)
        @repository.quote_identifier("#{field.mapping.name}.#{field.name}")
      end

      def normalize_value(value)
        if value.is_a?(Beacon::Mappings::Field)
          @repository.quote_identifier("#{value.mapping.name}.#{value.name}")
        else
          "?"
        end
      end
    end
  end
end