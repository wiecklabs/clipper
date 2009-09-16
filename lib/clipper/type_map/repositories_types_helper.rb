module Clipper
  class TypeMap
    class RepositoriesTypesHelper
      def initialize(types_module)
          unless types_module.is_a?(Module)
            raise ArgumentError.new("#{self.class}:types_module should be a module of repositories types but was #{types_module.inspect}")
          end
          @types_module = types_module
        end

        def method_missing(method, *args)
          # TODO: Is there a better way of doing this?
          type_class = method.to_s.split('_').map{|str| str.capitalize}.join
          @types_module.const_get(type_class)
        rescue NameError
          raise UnknownTypeError.new(method)
        end
    end # class SignatureHelper
  end # class TypeMap
end # module Clipper