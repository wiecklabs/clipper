module Clipper
  module Accessors

    ##
    # Include this module and define a class level #load method.
    ##
    module Serializable

      def self.included(target)
        target.send(:extend, ClassMethods)
      end

      module ClassMethods
        def load(value)
          if Clipper::Accessors > self && !accessors.empty?
            instance = new

            case value
            when Hash
              accessors.values.zip(value.values) { |accessor, value| accessor.set(instance, value) }
            when Array
              accessors.values.zip(value) { |accessor, value| accessor.set(instance, value) }
            else
              raise Clipper::Accessors::SerializationError.new(self, value)
            end

            instance
          else
            raise Clipper::Accessors::SerializationError.new(self, value)
          end
        end
      end

    end

  end
end