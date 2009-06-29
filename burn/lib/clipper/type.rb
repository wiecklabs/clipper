module Clipper

  class UnsupportedTypeError < StandardError
    def initialize(type)
      super("#{type} is not supported in this repository")
    end
  end

  class Type

    def self.inherited(target)
      Clipper::Types[target.name] = Clipper::Types[target.name.split("::").last] = target
    end

  end
end