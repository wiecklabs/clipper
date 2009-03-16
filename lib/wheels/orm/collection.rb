module Wheels
  module Orm
    class Collection

      include Test::Unit::Assertions

      include Enumerable

      def initialize(mapping, collection)
        raise ArgumentError.new("Collection must be initialized with an array") unless collection.is_a?(Array)
        @collection = collection

        @mapping = mapping
      end

      def mapping
        @mapping
      end

      def each
        @collection.each { |object| yield object }
      end

      def add(item)
        @collection << item
      end
      alias << add

      def size
        @collection.size
      end

      def first
        @collection.first
      end
      
      def [](index)
        entries[index]
      end

    end
  end
end