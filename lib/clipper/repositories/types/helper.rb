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
          # TODO: Is there a better way of doing this?
          type_class = method.to_s.split('_').map{|str| str.capitalize}.join
          type_class = @types_module.const_get(type_class)
          type = type_class.allocate
          type.send(:initialize, *args)
          type
        rescue NameError
          raise UnknownTypeError.new(method)
        end
      end
    end
  end
end