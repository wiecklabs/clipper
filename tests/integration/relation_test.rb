require "helper"

class RelationTest < Test::Unit::TestCase

  def setup
    @authors = Wheels::Orm::Mappings::Mapping.new("authors")
    @authors.key(@authors.field "id", Wheels::Orm::Repositories::Types::Integer)

    @stories = Wheels::Orm::Mappings::Mapping.new("stories")
    @stories.key(@stories.field "id", Wheels::Orm::Repositories::Types::Integer)
    @stories.field "author_id", Wheels::Orm::Repositories::Types::Integer
  end

  def test_requires_two_arguments
    assert_equal(Wheels::Orm::Mappings::Relation.instance_method("initialize").arity, 2)
  end

  def test_has_a_target_and_reference
    relation = Wheels::Orm::Mappings::Relation.new(@authors["id"], @stories["author_id"])
    assert_equal(relation.key, @authors["id"])
    assert_equal(relation.reference, @stories["author_id"])
  end

  def test_only_accepts_fields
    assert_nothing_raised do
      Wheels::Orm::Mappings::Relation.new(@authors["id"], @stories["author_id"])
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Relation.new(nil, nil)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Relation.new("id", "author_id")
    end
  end

end