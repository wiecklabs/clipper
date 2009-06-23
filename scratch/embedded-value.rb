class Address # Our custom, embedded-value type
  include Clipper::Accessors
  include Clipper::Accessors::Serializable

  accessor :address => String
  accessor :address_2 => String
  accessor :city => String
  accessor :state => String
  accessor :zip_code => String

  # In most circumstances this method is probably unnecessary...
  def self.load(value)
    address = new

    if value.is_a?(SomethingUseful)
      # load it!
    else
      raise SerializationError.new("Don't know how to coerce #{value.inspect} to #{self}")
    end

    address
  end

end

class Zoo
  include Clipper::Accessors

  accessor :id => Integer
  accessor :name => String
  # Assigning an Address, Array, and Hash can be handled by the accessor defined here
  # since it points to a Serializable type (we can iterate over the defined accessors on
  # the type in-order). We could also default an Address on nil assignment if we require
  # Serializables to have parameterless constructors, which seems like a pretty reasonable
  # constraint. So a Serializable::load would only be used for special serializations.
  accessor :address => Address

  # We use a simple Proxy here to define the accessors to validate (The +zoo+ block-argument).
  # NOTE: constraints are now Domain Model specific, not Repository specific, so they are
  # defined outsite of the mappings and can be used without the O/RM functionality.
  # Also note that if we wanted more general constraints on Addresses, we could define those
  # on the Address directly and they would then apply to any model with an Address accessor.
  constrain("default") do |check, zoo|
    check.required(zoo.address.city)
    check.required(zoo.address.state)

    check.size(zoo.address.name, 100)
    check.size(zoo.address.state, 50)
  end

  orm.map(self, "zoos") do |zoos|
    # We can mix the Repository Types into this block so we don't need to specify the full
    # class names. ie: Clipper::Adapters::Postgres::Types::Serial.new
    zoos.field :id, Serial.new
    # The Field will use the bound-method name as the field-name by default.
    zoos.field :name, String.new(200)
    # Here we must specify the field names for the embedded-value.
    zoos.field :city, String.new(100, "address_address_1"),
                      String.new(100, "address_address_2"),
                      String.new(100, "address_city"),
                      String.new(50, "address_state"),
                      String.new(50, "address_zip_code")
  end

end