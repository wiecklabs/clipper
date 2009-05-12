require Pathname(__FILE__).dirname + "field"

module Clipper
  class Mappings

    class Mapping

      class DuplicateFieldError < StandardError
      end

      class MultipleKeyError < StandardError
      end

      class DuplicateAssociationError < StandardError
      end

      def initialize(mappings, target, name)
        raise ArgumentError.new("Mapping#target must be a Class") unless target.kind_of?(Class)
        @target = target

        raise ArgumentError.new("Mapping#name must be a String") unless name.is_a?(String)
        raise ArgumentError.new("Mapping#name must not be blank") if name.blank?
        @name = name

        @mappings = mappings
        @fields = java.util.LinkedHashSet.new
        @key = java.util.LinkedHashSet.new
        @associations = java.util.LinkedHashSet.new
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
      
      def associations
        @associations
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
        @fields.detect { |field| field.name == name }
      end

      def belongs_to(name, mapped_name, &match_criteria)
        add_association BelongsTo.new(self, name, mapped_name, &match_criteria)
      end
      alias belong_to belongs_to

      def has_many(name, mapped_name, &match_criteria)
        add_association HasMany.new(self, name, mapped_name, &match_criteria)
      end
      alias have_many has_many

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

      # TODO: Mapping#keys? This doesn't really make sense, maybe key_fields?
      def keys
        @key
      end

      private

      def add_association(association)
        if @associations.include?(association)
          raise DuplicateAssociationError.new("Association #{association} is already a member of Mapping #{name.inspect}")
        else
          @associations << association
          association.class.bind!(association, target)
          association
        end
      end
      

    end
  end
end