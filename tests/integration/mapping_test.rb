require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::MappingTest < Test::Unit::TestCase

  def setup
    Wheels::Orm::Repositories::register("default", "abstract://localhost/example")
  end

  def teardown
    Wheels::Orm::Repositories::registrations.delete("default")
  end

  # This test describes the internal mappings use by the Wheels O/RM.
  # Some Adapters will retrive most of this mapping information from the database
  # saving you the work of having to define it yourself. When that is not possible,
  # (your database or storage system doesn't provide a mechanism to reflect on it's
  # schema) you will have to manually declare this information.
  def test_describing_a_simple_mapping
    assert_nothing_raised do

      # Let's assume we're mapping a database here for the sake of clarity and not a
      # mail server, web-service or other such storage provider.

      # The "people" Mapping here would map to the "people" table in our database.
      people = Wheels::Orm::Mappings::Mapping.new(Class.new, "people")

      # The fields in our mappings are added to an ordered-set. This means their order
      # is deterministic, and should reflect the same order as the underlying schema
      # for best results.
      # The Mapping#field method accepts two arguments and returns a Field object. The
      # first argument is the name of the field, in our case, a column name. The second
      # is the data-type of the field. This is not the type of the object accessor the
      # field is mapped to; it's the data-type of the column in the database.
      #
      # In other words, Person#marital_status could be an Integer, but it could also be
      # a String, an Enum or a BigDecimal. The data-type specified by the storage mechanism
      # isn't necessarily directly related to the type returned by a loaded object's
      # mapped accessor, this information is simply used to optimize how values are stored
      # and provide some flexibility in mapping them uniformally to objects.
      age = people.field "age", Wheels::Orm::Types::Integer
      marital_status = people.field "marital_status", Wheels::Orm::Types::Integer

      # Typically we would want our keys to appear first in our mappings, but we needed
      # to talk about fields first.
      #
      # Why would we want them to appear first? Simply because in a database table for
      # example you'd have your keys appear first, and declaring our mappings in this
      # same order ensures that if our table is generated from our mappings that we
      # get the expected result.
      #
      # The Mapping#key method accepts a variable number of fields belonging to the
      # mapping (to support composite keys). Since the Mapping#field method returns a
      # Field object, we can define our mappings and set the keys in the same step as the
      # code below, or we could define them separately like so:
      #
      #   first_name = people.field("first_name", Wheels::Orm::Repositories::Types::String)
      #   last_name = people.field("last_name", Wheels::Orm::Repositories::Types::String)
      #   people.key(first_name, last_name)
      people.key(
        people.field("first_name", Wheels::Orm::Types::String),
        people.field("last_name", Wheels::Orm::Types::String)
      )

      # Alternatively, if you want just one field, you can use the Mapping#[] method to
      # fetch it.
      assert_equal(people["age"], age)

      # Adding an already defined field will result in a DuplicateFieldError.
      assert_raise(Wheels::Orm::Mappings::Mapping::DuplicateFieldError) do
        people.field("age", Wheels::Orm::Types::Integer)
      end

      # A Mapping should have one (and only one) key defined.
      assert_raise(Wheels::Orm::Mappings::Mapping::MultipleKeyError) do
        people.key(people["age"])
      end
    end
  end

  def test_related_keys_are_already_defined_when_composing
    person = Class.new
    people = orm.map(person, "people") {}
    assert_raise(ArgumentError) { people.compose("localities", "city", "state") }
  end

  def test_describing_mapping_a_complete_class
    person = Class.new
    people = orm.map(person, "people") do |people|
      people.key people.field("id", Integer)
      people.field "name", String
      people.field "organization_id", Integer
      people.field "address_id", Integer
    end

    addresses = people.compose("addresses", "address_id") do |address|
      address.key address.field("id", Integer)
      address.field "city", String
      address.field "state", String
    end

    assert_kind_of(Wheels::Orm::Mappings::CompositeMapping, addresses)

    localities = people.compose("localities", "city", "state") do |locality|
      locality.key locality.field("city", String), locality.field("state", String)
      locality.field "zip", String
    end

    assert_kind_of(Wheels::Orm::Mappings::CompositeMapping, localities)
    assert_equal(2, people.composite_mappings.size)

    people.proxy("organization") { |p| orm.get(Organization, p.organization_id) }
    people.proxy("tasks") { |p| orm.all(Task, [:eql, "person_id", p.id]) }

    people.proxy("projects") do |p|
      task = orm.mappings[Task]
      orm.all(Projects, [:and, [:eql, task["person_id"], p.id], [:eql, "id", task["project_id"]]])
    end

  end

end