module Wheels
  module Orm
    class Mappings
      class CompositeMapping < Mapping

        def initialize(source_mapping, name, source_keys)
          raise ArgumentError.new("CompositeMapping#source_mapping must be a Mapping") unless source_mapping.is_a?(Mapping)
          @source_mapping = source_mapping

          raise ArgumentError.new("CompositeMapping#name must be a String") unless name.is_a?(String)
          raise ArgumentError.new("CompositeMapping#name must not be blank") if name.blank?
          @name = name

          @target = @source_mapping.target
          @source_keys = source_keys

          @fields = java.util.LinkedHashSet.new
          @key = java.util.LinkedHashSet.new
        end

        def source_keys
          @source_keys
        end

      end
    end
  end
end