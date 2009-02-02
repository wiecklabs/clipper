module Wheels
  module Orm
    module Validations
      class Contexts
        
        def initialize(mapping)
          @mapping = mapping
          @contexts = {}
        end
        
        def mapping
          @mapping
        end
        
        def eql?(other)
          other.is_a?(Contexts) && @mapping == other.mapping
        end
        
        def hash
          @hash ||= [self.class, @mapping].hash
        end
        
        def define(name, &block)
          unless name.is_a?(String)
            raise ArgumentError.new("Wheels::Orm::Validations::Contexts#define:name must be a String")
          end
          
          unless @contexts[name].nil?
            raise ArgumentError.new("You can not redefine an existing context")
          end
          
          unless block
            raise ArgumentError.new("Wheels::Orm::Validations::Contexts#define requires a block")
          end
          
          @contexts[name] = Wheels::Orm::Validations::Context.new(@mapping, name, &block)
        end
      end
    end
  end # module Orm
end # module Wheels