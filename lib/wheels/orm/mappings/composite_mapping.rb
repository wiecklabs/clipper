module Wheels
  module Orm
    class Mappings
      class CompositeMapping < Mapping

        def initialize(source_mapping, name)
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

          # We need an Set that preserves insertion order here.
          # The Wieck::OrderedSet is a temporary hack, not intended to be a
          # long term solution. I suspect jRuby offers an "out of box"
          # solution. Possibly jRuby's own Set preserves insertion order since
          # Java Hashes do?
          @fields = java.util.LinkedHashSet.new
          @key = java.util.LinkedHashSet.new
        end

        def field(*args)
          field = super
          @source_mapping.fields << field
          field
        end

      end
    end
  end
end