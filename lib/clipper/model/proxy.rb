module Clipper
  module Model
    class Proxy
      class Value
        def initialize(field, original, current)
          @field = field
          @original = original
          @current = current
        end

        def field
          @field
        end

        def get
          @current
        end

        def original
          @original
        end

        def dirty?
          @original != @current
        end
      end

      def initialize(model, mapping, original_values = {})
        raise ArgumentError.new('+mapping+ must be a Clipper::Mapping') unless mapping.is_a?(Clipper::Mapping)
        raise ArgumentError.new('+original_values+ must be a Hash or nil') unless original_values.is_a?(Hash) or original_values.nil?

        @model = model
        @mapping = mapping
        @original_values = original_values
      end

      def dirty_values
        values.select{|value| value.dirty?}
      end

      def values
        @values ||= @mapping.fields.map do |field|
          original = @original_values.nil? ? nil : @original_values[field]
          Value.new(field, original, field.accessor.get(@model))
        end
      end
    end
  end
end