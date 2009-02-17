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

          @composite_mappings = []
          @fields = java.util.LinkedHashSet.new
          @key = java.util.LinkedHashSet.new
          @contexts = Wheels::Orm::Validations::Contexts.new(self)
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

          unless missing_keys.empty?
            raise ArgumentError.new("The keys #{missing_keys.inspect} for composing #{mapped_name} are not defined.")
          end

          composite_mapping = Wheels::Orm::Mappings::CompositeMapping.new(self, mapped_name, related_keys)
          @composite_mappings << yield(composite_mapping)
          composite_mapping
        end

        def proxy(mapped_name)
          mapping = self
          criteria = Wheels::Orm::Query::Criteria.new(self)

          target.send(:instance_variable_set, "@#{mapped_name}_criteria", yield(criteria))

          target.send(:define_method, mapped_name) do
            # @proxy_query = yield(mapping)
            # @proxy_query.call(self)
          end

          target.send(:define_method, mapped_name+"=") do |object|
            self.send(mapped_name)
          end
        end

        def constrain(context_name, &block)
          @contexts.define(context_name, &block)
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

        def composite_fields
          composite_fields = java.util.LinkedHashSet.new
          @composite_mappings.each { |mapping| mapping.fields.each { |field| composite_fields.add(field) } }
          composite_fields
        end

        def keys
          @key
        end

        def composite_mappings
          @composite_mappings
        end
      end
    end
  end
end