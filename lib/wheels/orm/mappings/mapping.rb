require Pathname(__FILE__).dirname + "field"

module Wheels
  module Orm
    class Mappings

      class Mapping

        class DuplicateFieldError < StandardError
        end

        class MultipleKeyError < StandardError
        end

        def initialize(mappings, target, name)
          raise ArgumentError.new("Mapping#target must be a Class") unless target.kind_of?(Class)
          @target = target

          raise ArgumentError.new("Mapping#name must be a String") unless name.is_a?(String)
          raise ArgumentError.new("Mapping#name must not be blank") if name.blank?
          @name = name

          @mappings = mappings
          @composite_mappings = []
          @fields = java.util.LinkedHashSet.new
          @key = java.util.LinkedHashSet.new
          @validation_contexts = Wheels::Orm::Validations::Contexts.new(self)
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

        def mappings
          @mappings
        end

        def field(name, type, default_value = nil)
          field = Field.new(self, name, type, default_value)
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
          @fields.detect { |field| field.name == name } || composite_fields.detect { |field| field.name == name }
        end

        def compose(mapped_name, *related_keys)
          missing_keys = related_keys.reject { |related_key| self[related_key] }

          unless missing_keys.empty?
            raise ArgumentError.new("The keys #{missing_keys.inspect} for composing #{mapped_name} are not defined.")
          end

          related_keys.map! { |key| self[key] }

          composite_mapping = Wheels::Orm::Mappings::CompositeMapping.new(self, mapped_name, related_keys)
          yield(composite_mapping)
          @composite_mappings << composite_mapping
          composite_mapping
        end

        def belongs_to(name, mapped_name, &match_criteria)
          mapping = self
          associated_mapping = mapping.mappings[mapped_name]
          
          target.send(:define_method, name) do
            criteria1 = Wheels::Orm::Query::Criteria.new(mapping)
            criteria = match_criteria.call(self, Wheels::Orm::Query::Criteria.new(associated_mapping))

            # c = criteria.__conditions__
            # c.field.get(self)

            # __session__ ? __session__.find(mapping, criteria.__options__, criteria.__conditions__) : nil
            orm.find(associated_mapping, criteria.__options__, criteria.__conditions__).first
          end

          target.send(:define_method, "#{name}=") do |object|
            criteria1 = Wheels::Orm::Query::Criteria.new(mapping)
            criteria = match_criteria.call(criteria1, Wheels::Orm::Query::Criteria.new(mapping.mappings[mapped_name]))

            c = criteria.__conditions__
            c.value.field.set(self, c.field.get(object))
          end
        end

        alias belong_to belongs_to


        def constrain(context_name, &block)
          @validation_contexts.define(context_name, &block)
        end

        def eql?(other)
          other.is_a?(Mapping) && name == other.name
        end
        alias == eql?

        def hash
          @hash ||= name.hash
        end

        def validate(object, context_name)
          @validation_contexts[context_name].validate(object)
        end

        ##
        # @api private
        #
        def fields
          @fields
        end

        def composite_fields
          composite_fields = java.util.LinkedHashSet.new
          @composite_mappings.each do |mapping|
            mapping.fields.each do |field|
              composite_fields.add(field) unless mapping.keys.include?(field)
            end
          end
          composite_fields
        end

        # TODO: Mapping#keys? This doesn't really make sense, maybe key_fields?
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