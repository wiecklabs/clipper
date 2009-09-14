module Clipper
  module Repositories
    module Types
      class Helper
        def initialize(types_module)
          unless types_module.is_a?(Module)
            raise ArgumentError.new("#{self.class}:types_module should be a module of repositories types but was #{types_module.inspect}")
          end
          @types_module = types_module
        end

        def method_missing(method, *args)
          type = @types_module.const_get(method.to_s.capitalize)
          type = type.allocate
          type.send(:initialize, *args)
          type
        rescue NameError
          raise UnknownTypeError.new(method)
        end

        class UnknownTypeError < StandardError
          def initialize(type)
            super("Unkown type #{type.to_s}")
          end
        end
      end
    end
  end
end