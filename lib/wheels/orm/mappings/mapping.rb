require Pathname(__FILE__).dirname + "field"

module Wheels
  module Orm
    module Mappings
      class Mapping
        
        include Test::Unit::Assertions
        
        def initialize(name)
          assert_kind_of(String, name, "Mapping#name must be a String")
          assert(!Helpers::blank?(name), "Mapping#name must not be blank")
          @name = name
          
          @fields = []
          @keys = []
        end
        
        # The name of this mapping. In database terms this would map to a
        # table name. The name must be known up-front, set in the initializer
        # and not modified once set.
        def name
          @name
        end
        
        def field(name, type)
          field = Field.new(name, type)
          if @fields.include?(field)
            raise ArgumentError.new("Field #{name}:#{type} is already a member of Mapping #{name.inspect}")
          else
            @fields << field
          end
        end
        
        def key(*fields)
          @keys.concat(fields)
          self
        end
      end
    end
  end
end