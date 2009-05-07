module Clipper
  module Model

    def self.included(target)
      target.send(:extend, Clipper::Session::Helper)
    end

    def __session__
      @__session__
    end

    def hash
      @__session__.key(self).hash
    end

    def eql?(other)
      @__session__.key(self) == other.__session__.key(other)
    end
    alias == eql?

  end
end