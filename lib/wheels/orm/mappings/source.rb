require Pathname(__FILE__).dirname + "field"

module Wheels
  module Orm
    module Mappings
      class Source

        class DuplicateFieldError < StandardError
        end
        
        class MultipleKeyError < StandardError
        end
        
        include Test::Unit::Assertions
        
        def initialize(name)
          assert_kind_of(String, name, "Mapping#name must be a String")
          assert(!name.blank?, "Mapping#name must not be blank")
          @name = name
          
          # We need an Set that preserves insertion order here.
          # The Wieck::OrderedSet is a temporary hack, not intended to be a
          # long term solution. I suspect jRuby offers an "out of box"
          # solution. Possibly jRuby's own Set preserves insertion order since
          # Java Hashes do?
          @fields = Wieck::OrderedSet.new
          @key = Wieck::OrderedSet.new
        end
        
        # The name of this mapping. In database terms this would map to a
        # table name. The name must be known up-front, set in the initializer
        # and not modified once set.
        def name
          @name
        end
        
        def field(name, type)
          if @fields.detect { |field| field.name == name }
            raise DuplicateFieldError.new("Field #{name}:#{type} is already a member of Mapping #{name.inspect}")
          else
            @fields << (field = Field.new(name, type))
            field
          end
        end
        
        def key(*fields)
          if @key.empty?
            fields.each do |field|
              @fields << field unless @fields.include?(field)
              @key << field
            end
          else
            raise MultipleKeyError.new("The key for Source<#{name}> is already defined as #{@key.inspect}")
          end
          
          self
        end
        
        def [](name)
          @fields.detect { |field| field.name == name }
        end
        
        def fields(*names)
          @fields.select { |field| names.include?(field.name) }
        end
      end
    end
  end
end