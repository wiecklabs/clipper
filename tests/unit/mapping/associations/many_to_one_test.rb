require "pathname"
require Pathname(__FILE__).dirname.parent.parent.parent + "helper"

class ManyToOneTest < Test::Unit::TestCase
  ManyToOne = Clipper::Mapping::ManyToOne

  def setup
    uri = Clipper::Uri.new("abstract://localhost/example")
    @repository = Clipper::registrations["default"] = Clipper::Repositories::Abstract.new("abstract", uri)

    @parent_class = Class.new do
      include Clipper::Model

      orm.map(self, 'parent') do |parent, type|
        parent.property :id, Integer, type.serial

        parent.key :id
      end
    end

    @child_class = Class.new do
      include Clipper::Model

      orm.map(self, 'children') do |child, type|
        child.property :id, Integer, type.serial
        child.property :parent_id, Integer, type.integer

        child.key :id
      end
    end

    @child_mapping = @repository.mappings[@child_class]

    @association = ManyToOne.new(@child_mapping, :parent, @parent_class) do |child, parent|
      parent.id.eq(child.parent_id)
    end
  end

  def test_requires_match_criteria
    assert_raise(ArgumentError) do
      ManyToOne.new(@child_mapping, :parent, @child_class)
    end
  end

  def test_associated_mapping
    assert_nothing_raised do
      @association.associated_mapping
    end
  end

  def test_set_key
    parent = @parent_class.new
    parent.id = 1
    child = @child_class.new

    @association.set_key(child, parent)

    assert_equal(parent.id, child.parent_id)
  end

  def test_unlink
    parent = @parent_class.new
    parent.id = 2
    child = @child_class.new

    @association.set_key(child, parent)
    @association.unlink(child)

    assert_nil(child.parent_id)
  end

  def test_bind!
    ManyToOne.bind!(@association, @child_class)

    assert(@child_class.new.respond_to?(:parent))
    assert(@child_class.new.respond_to?(:parent=))
  end
end