module Integration::AbstractRepositoryTest

  def setup_abstract
    @zoo = Class.new do
      orm.map(self, "zoos") do |zoos|
        zoos.key zoos.field("id", Wheels::Orm::Types::Serial)
        zoos.field "name", String
      end
    end

    @city = Class.new do
      orm.map(self, "cities") do |cities|
        cities.field("name", String)
        cities.field("state", String)
        cities.key(cities["name"], cities["state"])
      end
    end

    @person = Class.new do
      orm.map(self, "people") do |people|
        people.key people.field("id", Wheels::Orm::Types::Serial)
        people.field "name", String
        people.field "gpa", Float
      end
    end
  end

  def test_schema_create
    schema = Wheels::Orm::Schema.new("default")
    assert(!schema.exists?(@zoo))
    assert_nothing_raised do
      schema.create(@zoo)
    end
    assert(schema.exists?(@zoo))
  ensure
    schema.destroy(@zoo)
  end

  def test_schema_exists
    schema = Wheels::Orm::Schema.new("default")
    assert(!schema.exists?(@city))
  end

  def test_schema_destroy
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@zoo)
    assert_nothing_raised do
      schema.destroy(@zoo)
    end
  end

  def test_field_exists
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@city)
    orm.repository.with_connection do |connection|
      columns = connection.getMetaData.getColumns(nil, nil, "cities", "state")
      assert(columns.next)
    end
  ensure
    schema.destroy(@city)
  end

  def test_save_object
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@zoo)
    zoo = @zoo.new
    zoo.name = "Dallas"

    assert_nothing_raised { orm.save(zoo) }
    assert_not_nil(zoo.id)

  ensure
    schema.destroy(@zoo)
  end

  def test_support_for_floats
    schema = Wheels::Orm::Schema.new("default")
    assert_nothing_raised { schema.create(@person) }
    person = @person.new
    person.gpa = 3.5

    assert_nothing_raised do
      orm.save(person)
    end

    assert_equal(3.5, orm.get(@person, person.id).gpa)
  ensure
    schema.destroy(@person)
  end

  def test_insert_multiple_records
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person1 = @person.new
    person1.name = "John"

    person2 = @person.new
    person2.name = "Jane"

    people = Wheels::Orm::Collection.new(orm.mappings[@person], [person1, person2])

    orm.save(people)

    assert_not_nil(person1.id)
    assert_not_nil(person2.id)
  ensure
    schema.destroy(@person)
  end

  def test_get_object
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person = @person.new
    person.name = "John"
    person.gpa = 3.5
    orm.save(person)

    assert_nothing_raised do
      john = orm.get(@person, person.id)
      assert_equal("John", john.name)
      assert_equal(3.5, john.gpa)
    end

  ensure
    schema.destroy(@person)
  end

  def test_get_object_with_compound_key
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@city)

    city = @city.new
    city.name = "Dallas"
    city.state = "Texas"
    orm.save(city)

    assert_nothing_raised do
      city = orm.get(@city, "Dallas", "Texas")
      assert_not_nil(city)
      assert_equal("Dallas", city.name)
      assert_equal("Texas", city.state)
    end

  ensure
    schema.destroy(@city)
  end

  def test_all
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person = @person.new
    person.name = "John"
    person.gpa = 3.5
    orm.save(person)

    person = @person.new
    person.name = "James"
    person.gpa = 3.2
    orm.save(person)

    assert_nothing_raised do
      people = orm.all(@person)
      assert_equal(2, people.size)
    end

  ensure
    schema.destroy(@person)
  end

  def test_all_with_raw_conditions
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person = @person.new
    person.name = "John"
    person.gpa = 3.5
    orm.save(person)

    person = @person.new
    person.name = "James"
    person.gpa = 2
    orm.save(person)

    assert_nothing_raised do
      low_gpa = Wheels::Orm::Query::UnboundCondition.lt(orm.mappings[@person]["gpa"], 3)
      people = orm.all(@person, low_gpa)
      assert_equal(1, people.size)
    end

  ensure
    schema.destroy(@person)
  end
  
  def test_all_with_nice_conditions
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)
    
    jimmy = @person.new
    jimmy.name = "Jimmy"
    jimmy.gpa = 3.5
    orm.save(jimmy)
    
    assert_nothing_raised do
      people = orm.all(@person, :limit => 1) { |person| person.gpa.gt(3).or(person.name.eq("Jimmy")) }
      assert_equal(1, people.size)
    end
  ensure
    schema.destroy(@person)
  end
end