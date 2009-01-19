module Wheels
  module Orm
    module Mappings
      class CompositeMapping < Mapping

        def initialize(source_mapping, name)
          @source_mapping = source_mapping
          super(name)
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