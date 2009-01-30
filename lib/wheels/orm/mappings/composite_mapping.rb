module Wheels
  module Orm
    class Mappings
      class CompositeMapping < Mapping

        def initialize(source_mapping, name, source_keys)
          begin
            assert_kind_of(Mapping, source_mapping, "CompositeMapping#source_mapping must be a Mapping")
            @source_mapping = source_mapping

            assert_kind_of(String, name, "CompositeMapping#name must be a String")
            assert_not_blank(name, "CompositeMapping#name must not be blank")
            @name = name
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end

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