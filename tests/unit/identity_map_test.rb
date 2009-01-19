require "helper"

class IdentityMapTest < Test::Unit::TestCase

  def test_has_a_name_and_type
    field = Wheels::Orm::Mappings::Field.new("name", Wheels::Orm::Types::String)
    assert_equal(field.name, "name")
    assert_equal(field.type, Wheels::Orm::Types::String)
  end

  def test_only_accepts_defined_types
    assert_nothing_raised do
      Wheels::Orm::Mappings::Field.new("name", Wheels::Orm::Types::String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new("name", String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new("name", nil)
    end
  end

  def test_must_have_a_valid_name
    assert_nothing_raised do
      Wheels::Orm::Mappings::Field.new("name", Wheels::Orm::Types::String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new("    ", Wheels::Orm::Types::String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(nil, Wheels::Orm::Types::String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(:name, Wheels::Orm::Types::String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(Object.new, Wheels::Orm::Types::String)
    end
  end

end