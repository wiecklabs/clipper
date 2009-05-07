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
      # HACK: shouldn't this check the collection's session instance rather than each instances session?
      collection = self.class.new(@mapping, @collection.reject { |object| object.__session__ && object.__session__.stored?(object) })
      collection.instance_variable_set("@session", @session)
      collection
    end

    def stored_entries
      # HACK: shouldn't this check the collection's session instance rather than each instances session?
      collection = self.class.new(@mapping, @collection.select { |object| object.__session__ && object.__session__.stored?(object) })
      collection.instance_variable_set("@session", @session)
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

    def session
      @session
    end

    def session=(session)
      @session = session
      each do |item|
        item.instance_variable_set("@__session__", @session)
      end
    end

    def [](index)
      entries[index]
    end

  end
end