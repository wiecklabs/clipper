module Clipper

  module Validations

    def self.included(target)
      target.instance_variable_set(:@validation_contexts, {})
      target.extend(ClassMethods)
    end

    def valid?(context_name = 'default')
      if context = self.class.__validation_contexts__[context_name]
        context.validate(self)
      else
        raise ArgumentError.new("No constraints are defined for #{instance.class.inspect} within the #{context_name} context.")
      end
    end

    module ClassMethods

      def __validation_contexts__
        @__validation_contexts__ ||= {}
      end

      def constrain(context_name, &block)
        __validation_contexts__[context_name] = Clipper::Validations::Context.new(self, context_name, &block)
      end

    end

  end # module Validations
end # module Clipper