module Beacon

  @validation_context_map = {}

  def self.constrain(target, context_name, &block)
    @validation_context_map[context_name] ||= {}
    @validation_context_map[context_name][target] = Beacon::Validations::Context.new(target, context_name, &block)
  end

  def self.validate(instance, context_name = 'default')
    if context_map = @validation_context_map[context_name]
      if context = context_map[instance.class]
        return context.validate(instance)
      else
        raise ArgumentError.new("No constraints are defined for #{instance.class.inspect} within the #{context_name} context.")
      end
    else
      raise ArgumentError.new("The validation context #{context_name} is not defined")
    end
  end

end # module Beacon