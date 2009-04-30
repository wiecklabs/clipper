module Beacon

  class UnsupportedTypeError < StandardError
    def initialize(type)
      super("#{type} is not supported in this repository")
    end
  end

  class Type

    def self.inherited(target)
      Beacon::Types[target.name] = Beacon::Types[target.name.split("::").last] = target
    end

  end
end