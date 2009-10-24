module Clipper
  class Collection

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

    def new_entries
      collection = Collection.new(@mapping, @collection.reject { |object| object && object.__session__ && object.__session__.stored?(object) })
      collection
    end

    def stored_entries
      collection = Collection.new(@mapping, @collection.select { |object| object && object.__session__ && object.__session__.stored?(object) })
      collection
    end

    def add(item)
      @collection << item

      item
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

    def |(items)
      @collection | items
      self
    end

  end
end