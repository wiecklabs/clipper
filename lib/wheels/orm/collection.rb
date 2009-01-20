module Wheels
  module Orm
    class Collection

      include Test::Unit::Assertions

      def initialize(collection)
        raise ArgumentError.new("Collection must be initialized with an array") unless collection.is_a?(Array)
        @collection = collection
      end

      def each
        @collection.each { |object| yield object }
      end
    end
  end
end