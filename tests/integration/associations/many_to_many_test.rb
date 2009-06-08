require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname.parent + "sample_models"

class ManyToManyTest < Test::Unit::TestCase

  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")

    schema = Clipper::Schema.new("default")
    schema.create(Zoo)
    schema.create(ZooKeeper)
    schema.create(Exhibit)

    orm do |session|
      @zoo = Zoo.new('Dallas')
      @zoo.exhibits = [Exhibit.new('Bat'), Exhibit.new('Snake'), Exhibit.new('Frog')]
      session << @zoo
    end
  end

  def teardown
    schema = Clipper::Schema.new("default")
    schema.destroy(Zoo)
    schema.destroy(ZooKeeper)
    schema.destroy(Exhibit)

    Clipper::close("default")
  end

  def test_creates_anonymous_mapping
    @mapping = nil

    Clipper::Mappings['default'].each { |m| @mapping = m if m.name == 'exhibits_zoo_keepers' }

    assert_not_nil(@mapping)
  end

  def test_defines_getter_and_setter
    amber = ZooKeeper.new('Amber')
    assert_respond_to(amber, :exhibits)
    assert_respond_to(amber, :exhibits=)
  end

  def test_saving_all_new_objects
    exhibit = Exhibit.new('Human Baby')

    orm do |session|
      amber = ZooKeeper.new('Amber')
      amber.exhibits = [exhibit]
      session << amber
    end

    amber = orm.get(ZooKeeper, 0)

    assert_equal(1, orm.all(ZooKeeper).size)
    assert_equal(4, orm.all(Exhibit).size)
    assert_equal(1, amber.exhibits.size)
    assert_equal(exhibit, amber.exhibits.first)
  end

  def test_setter_overwrites_current_associations
    exhibit1 = Exhibit.new('Human Baby')
    exhibit2 = Exhibit.new('Dog')

    orm do |session|
      amber = ZooKeeper.new('Amber')
      amber.exhibits = [exhibit1]
      session << amber
    end

    orm do |session|
      amber = session.get(ZooKeeper, 0)
      amber.exhibits = [exhibit2]
      session << amber
    end

    amber = orm.get(ZooKeeper, 0)

    assert_equal(1, orm.all(ZooKeeper).size)
    assert_equal(5, orm.all(Exhibit).size)
    assert_equal(1, amber.exhibits.size)
    assert_equal(exhibit2, amber.exhibits.first)
  end

  def test_multiple_appends
    exhibit1 = Exhibit.new('Human Baby')
    exhibit2 = Exhibit.new('Dog')

    orm do |session|
      amber = ZooKeeper.new('Amber')
      amber.exhibits = [exhibit1]
      session << amber
    end

    orm do |session|
      amber = session.get(ZooKeeper, 0)
      amber.exhibits << exhibit2
      session << amber
    end

    amber = orm.get(ZooKeeper, 0)

    assert_equal(1, orm.all(ZooKeeper).size)
    assert_equal(5, orm.all(Exhibit).size)
    assert_equal(2, amber.exhibits.size)
    assert_equal([exhibit1, exhibit2].sort, amber.exhibits.entries.sort)
  end

end