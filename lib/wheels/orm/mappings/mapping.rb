require Pathname(__FILE__).dirname + "field"

module Wheels
  module Orm
    class Mappings

      class Mapping

        class DuplicateFieldError < StandardError
        end

        class MultipleKeyError < StandardError
        end

        include Test::Unit::Assertions

        def initialize(target, name)
          begin
            assert_kind_of(Class, target, "Mapping#target must be a Class")
            @target = target

            assert_kind_of(String, name, "Mapping#name must be a String")
            assert_not_blank(name, "Mapping#name must not be blank")
            @name = name
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end

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

        def target
          @target
        end

        def field(name, type)
          field = Field.new(self, name, type)
          if @fields.include?(field)
            raise DuplicateFieldError.new("Field #{name}:#{type} is already a member of Mapping #{name.inspect}")
          else
            @fields << field
            Field.bind!(field, target)
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
            raise MultipleKeyError.new("The key for Mapping<#{name}> is already defined as #{@key.inspect}")
          end

          self
        end

        def [](name)
          @fields.detect { |field| field.name == name }
        end

        def compose(mapped_name, *related_keys)
          missing_keys = related_keys.reject { |related_key| self[related_key] }
          raise ArgumentError.new("The keys #{missing_keys.inspect} for composing #{mapped_name} are not defined.") unless missing_keys.empty?

          composite_mapping = Wheels::Orm::Mappings::CompositeMapping.new(self, mapped_name)
          yield composite_mapping
          composite_mapping
        end

        def proxy(mapped_name)
        end

        def eql?(other)
          other.is_a?(Mapping) && name == other.name
        end
        alias == eql?

        def hash
          @hash ||= name.hash
        end

        ##
        # @api private
        #
        def fields
          @fields
        end
      end
    end
  end
end