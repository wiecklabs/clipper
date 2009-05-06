module Clipper
  module Model

    def self.included(target)
      target.send(:extend, Clipper::Session::Helper)
    end

    def __session__
      @__session__
    end
  end
end