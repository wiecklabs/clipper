module Wheels
  module Orm
    module Validations
      class Context
        
        def initialize(mapping, name, &block)
          @mapping = mapping
          @name = name
          
        end
        
        def mapping
          @mapping
        end
        
        def name
          @name
        end
        
        def eql?(other)
          other.is_a?(Context) && @mapping == other.mapping && @name == other.name
        end
        
        def hash
          @hash ||= [@mapping, @name].hash
        end
      end
    end
  end # module Orm
end # module Wheels