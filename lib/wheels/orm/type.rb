module Wheels
  module Orm
    class Type

      def self.inherited(target)
        Wheels::Orm::Types[target.name] = Wheels::Orm::Types[target.name.split("::").last] = target
      end
    end
  end
end