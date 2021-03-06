require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class Integration::MappingTest < Test::Unit::TestCase

  def setup
    Clipper::open("default", "abstract://localhost/example")
  end

  def teardown
    Clipper::registrations.delete("default")
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
      people = Clipper::Mappings::Mapping.new(Clipper::Mappings.new, Class.new, "people")

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
      age = people.field "age", Clipper::Types::Integer
      marital_status = people.field "marital_status", Clipper::Types::Integer

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
      #   first_name = people.field("first_name", Clipper::Repositories::Types::String)
      #   last_name = people.field("last_name", Clipper::Repositories::Types::String)
      #   people.key(first_name, last_name)
      people.key(
        people.field("first_name", Clipper::Types::String.new(200)),
        people.field("last_name", Clipper::Types::String.new(200))
      )

      # Alternatively, if you want just one field, you can use the Mapping#[] method to
      # fetch it.
      assert_equal(people["age"], age)

      # Adding an already defined field will result in a DuplicateFieldError.
      assert_raise(Clipper::Mappings::Mapping::DuplicateFieldError) do
        people.field("age", Clipper::Types::Integer)
      end

      # A Mapping should have one (and only one) key defined.
      assert_raise(Clipper::Mappings::Mapping::MultipleKeyError) do
        people.key(people["age"])
      end
    end
  end

end