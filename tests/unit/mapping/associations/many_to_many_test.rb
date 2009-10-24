require "pathname"
require Pathname(__FILE__).dirname.parent.parent.parent + "helper"

class ManyToManyTest < Test::Unit::TestCase
  ManyToMany = Clipper::Mapping::ManyToMany

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

        child.key :id
      end
    end

    @parent_mapping = @repository.mappings[@parent_class]

    @association = ManyToMany.new(@repository, @parent_mapping, :children, @child_class, 'parent_child')
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
    child.id = 4

    join = @association.target_mapping.target.new(parent, child)

    @association.set_key(parent, child, join)

    assert_equal(parent.id, join.parent_id)
    assert_equal(child.id, join.children_id)
  end
  
  def test_bind!
    ManyToMany.bind!(@association, @parent_class)

    assert(@parent_class.new.respond_to?(:children))
    assert(@parent_class.new.respond_to?(:children=))
  end
end