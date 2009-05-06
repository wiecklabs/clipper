require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class RelationTest < Test::Unit::TestCase

  def setup
    @authors = Clipper::Mappings::Mapping.new(Clipper::Mappings.new, Class.new, "authors")
    @authors.key(@authors.field "id", Clipper::Types::Integer)

    @stories = Clipper::Mappings::Mapping.new(Clipper::Mappings.new, Class.new, "stories")
    @stories.key(@stories.field "id", Clipper::Types::Integer)
    @stories.field "author_id", Clipper::Types::Integer
  end

  def test_requires_two_arguments
    assert_equal(Clipper::Mappings::Relation.instance_method("initialize").arity, 2)
  end

  def test_has_a_target_and_reference
    relation = Clipper::Mappings::Relation.new(@authors["id"], @stories["author_id"])
    assert_equal(relation.key, @authors["id"])
    assert_equal(relation.reference, @stories["author_id"])
  end

  def test_only_accepts_fields
    assert_nothing_raised do
      Clipper::Mappings::Relation.new(@authors["id"], @stories["author_id"])
    end

    assert_raise(ArgumentError) do
      Clipper::Mappings::Relation.new(nil, nil)
    end

    assert_raise(ArgumentError) do
      Clipper::Mappings::Relation.new("id", "author_id")
    end
  end

end