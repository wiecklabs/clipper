module Beacon
  module Accessors

    def self.included(target)
      target.extend(ClassMethods)
    end

    module ClassMethods

      def accessors
        @accessors ||= {}
      end

      def accessor(methods)
        methods.each_pair do |name, type|
          accessors[name] = TypedAccessor.new(self, name, type)
        end
      end
    end
  end
end

require Pathname(__FILE__).dirname + "accessors" + "typed_accessor"
require Pathname(__FILE__).dirname + "accessors" + "serializable"