module Beacon
  module Model

    def self.included(target)
      target.send(:extend, Beacon::Session::Helper)
    end

    def __session__
      @__session__
    end
  end
end