module Clipper

  def self.validation_context_map
    @validation_context_map ||= {}
  end

  def self.validate(instance, context_name = 'default')
    if context_map = validation_context_map[context_name]
      if context = context_map[instance.class]
        return context.validate(instance)
      else
        raise ArgumentError.new("No constraints are defined for #{instance.class.inspect} within the #{context_name} context.")
      end
    else
      raise ArgumentError.new("The validation context #{context_name} is not defined")
    end
  end

  module Validations

    def self.included(target)
      target.extend(ClassMethods)
    end

    module ClassMethods
      def constrain(context_name, &block)
        Clipper::validation_context_map[context_name] ||= {}
        Clipper::validation_context_map[context_name][self] = Clipper::Validations::Context.new(self, context_name, &block)
      end

    end

  end # module Validations
end # module Clipper