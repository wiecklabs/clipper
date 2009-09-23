require "pathname"
require Pathname(__FILE__).dirname.parent.parent.parent + "helper"

class OneToManyTest < Test::Unit::TestCase
  OneToMany = Clipper::Mapping::OneToMany

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

    @parent_mapping = @repository.mappings[@parent_class]

    @association = OneToMany.new(@parent_mapping, :children, @child_class) do |parent, child|
      child.parent_id.eq(parent.id)
    end
  end

  def test_requires_match_criteria
    assert_raise(ArgumentError) do
      OneToMany.new(@parent_mapping, :children, @child_class)
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
    
    @association.set_key(parent, child)

    assert_equal(parent.id, child.parent_id)
  end

  def test_unlink
    parent = @parent_class.new
    parent.id = 2
    child = @child_class.new

    @association.set_key(parent, child)
    @association.unlink(parent, child)

    assert_nil(child.parent_id)
  end
  
  def test_bind!
    OneToMany.bind!(@association, @parent_class)
    
    assert(@parent_class.new.respond_to?(:children))
    assert(@parent_class.new.respond_to?(:children=))
  end
end