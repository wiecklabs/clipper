require "helper"

class SourceTest < Test::Unit::TestCase
  
  # This test describes the internal mappings use by the Wheels O/RM.
  # Some Adapters will retrive most of this mapping information from the database
  # saving you the work of having to define it yourself. When that is not possible,
  # (your database or storage system doesn't provide a mechanism to reflect on it's
  # schema) you will have to manually declare this information.
  def test_describing_a_simple_mapping
    assert_nothing_raised do
      
      # Let's assume we're mapping a database here for the sake of clarity and not a
      # mail server, web-service or other such storage provider.
      
      # The "people" Source here would map to the "people" table in our database.
      people = Wheels::Orm::Mappings::Source.new("people")
      
      # The fields in our mappings are added to an ordered-set. This means their order
      # is deterministic, and should reflect the same order as the underlying schema
      # for best results.
      # The Source#field method accepts two arguments and returns a Field object. The
      # first argument is the name of the field, in our case, a column name. The second
      # is the data-type of the field. This is not the type of the object accessor the
      # field is mapped to; it's the data-type of the column in the database.
      #
      # In other words, Person#marital_status could be an Integer, but it could also be
      # a String, an Enum or a BigDecimal. The data-type specified by the storage mechanism
      # isn't necessarily directly related to the type returned by a loaded object's
      # mapped accessor, this information is simply used to optimize how values are stored
      # and provide some flexibility in mapping them uniformally to objects.
      age = people.field "age", Wheels::Orm::Repositories::Types::Integer
      marital_status = people.field "marital_status", Wheels::Orm::Repositories::Types::Integer
      
      # Typically we would want our keys to appear first in our mappings, but we needed
      # to talk about fields first.
      # 
      # Why would we want them to appear first? Simply because in a database table for
      # example you'd have your keys appear first, and declaring our mappings in this
      # same order ensures that if our table is generated from our mappings that we
      # get the expected result.
      #
      # The Source#key method accepts a variable number of fields belonging to the
      # mapping (to support composite keys). Since the Source#field method returns a
      # Field object, we can define our mappings and set the keys in the same step as the
      # code below, or we could define them separately like so:
      #
      #   first_name = people.field("first_name", Wheels::Orm::Repositories::Types::String)
      #   last_name = people.field("last_name", Wheels::Orm::Repositories::Types::String)
      #   people.key(first_name, last_name)
      people.key(
        people.field("first_name", Wheels::Orm::Repositories::Types::String),
        people.field("last_name", Wheels::Orm::Repositories::Types::String)
      )
      
      # You can retrieve fields with the Source#fields method. Any number of field names are
      # passed in to look up, and an Array of the Fields is returned.
      assert_equal(people.fields("age"), [ age ])
      assert_equal(people.fields("age", "marital_status"), [ age, marital_status ])
      
      # Alternatively, if you want just one field, you can use the Source#[] method to
      # fetch it.
      assert_equal(people["age"], age)
      
      # Adding an already defined field will result in a DuplicateFieldError.
      assert_raise(Wheels::Orm::Mappings::Source::DuplicateFieldError) do
        people.field("age", Wheels::Orm::Repositories::Types::Integer)
      end
      
      # A Source should have one (and only one) key defined.
      assert_raise(Wheels::Orm::Mappings::Source::MultipleKeyError) do
        people.key(*people.fields("age"))
      end
    end
  end
  
end