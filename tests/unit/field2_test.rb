# Mappings:
#   Mapping[User]:
#     TableName
#     Fields: # def initialize(mapping, name, type, default = nil)
#       bound_method_name
#       ColumnName
#       Type (name, options[size, mantissa, etc])
#       Lazy?
#       DefaultValue: Function, lambda or primitive

require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Field2Test < Test::Unit::TestCase

  class Field

    private

    class Type
    end

    public

    class String < Type
      def initialize(size)
        raise ArgumentError.new("String#size must be an Integer") unless size.is_a?(Integer)
        raise ArgumentError.new("String#size must be non-zero") if size == 0
        @size = size
      end

      def size
        @size
      end

      def eql?(other)
        other.is_a?(String) && size == other.size
      end
      alias == eql?

      def hash
        @hash ||= size.hash
      end
    end

    attr_reader :name

    def initialize(bound_method_name, name, type)
      raise ArgumentError.new("Field#bound_method_name must be a String") unless bound_method_name.is_a?(::String)
      raise ArgumentError.new("Field#bound_method_name must not be blank") if bound_method_name.blank?
      @bound_method_name = bound_method_name

      raise ArgumentError.new("Field#name must be a String") unless name.is_a?(::String)
      raise ArgumentError.new("Field#name must not be blank") if name.blank?
      @name = name

      raise ArgumentError.new("Field#type must be a Wheels::Orm::Type") unless type.is_a?(Type)
      @type = type
    end

    def self.bind!(field, target)
      target.class_eval do
        define_method(field.bound_method_name) do
          field.get(self)
        end

        define_method("#{field.bound_method_name}=") do |value|
          field.set(self, value)
        end
      end
    end

    def get(object)
      object.instance_variable_get("@#{bound_method_name}")
    end

    def set(object, value)
      object.instance_variable_set("@#{bound_method_name}", value)
    end

    def bound_method_name
      @bound_method_name
    end

    def eql?(other)
      other.is_a?(Field) &&
        name == other.name &&
        bound_method_name == other.bound_method_name &&
        type == other.type
    end
    alias == eql?

    def hash
      @hash ||= [name, bound_method_name, type].hash
    end

    protected

    def type
      @type
    end
  end

  def test_two_fields_are_the_same
    assert_equal(
      Field.new("name", "name", Field::String.new(255)),
      Field.new("name", "name", Field::String.new(255))
    )
  end

  def test_field_can_bind_to_an_object
    field = Field.new("name", "name", Field::String.new(255))
    person = Class.new do
      attr_accessor :name
    end

    bob = person.new
    bob.name = "Bob"

    Field::bind!(field, person)

    assert_equal("Bob", field.get(bob))
    bob.name = "Ted"
    assert_equal("Ted", field.get(bob))
    field.set(bob, "Bob!")
    assert_equal("Bob!", bob.name)
  end

end