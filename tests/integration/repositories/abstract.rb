module Integration::AbstractRepositoryTest

  # class Zoo
  # end

  def setup_abstract
    @zoo = Class.new do
      Wheels::Orm::Mappings["default"].map(self, "zoos") do |zoos|
        zoos.key zoos.field("id", Wheels::Orm::Types::Serial)
        zoos.field "name", Wheels::Orm::Types::String.new(200)
        zoos.field "city", Wheels::Orm::Types::String.new(200)
        zoos.field "state", Wheels::Orm::Types::String.new(200)
        zoos.field "notes", Wheels::Orm::Types::Text

        cities = zoos.compose("cities", "city", "state") do |cities|
          cities.field("name", Wheels::Orm::Types::String.new(200))
          cities.field("state", Wheels::Orm::Types::String.new(200))
          cities.field("region", Wheels::Orm::Types::String.new(200))

          cities.key(cities["name"], cities["state"])
        end

        zoos.compose("climates", "region") do |climates|
          climates.field("region", Wheels::Orm::Types::String.new(200))
          climates.field("climate", Wheels::Orm::Types::String.new(200))

          climates.key(climates["region"])
        end
      end
    end

    @climate = Class.new do
      Wheels::Orm::Mappings["default"].map(self, "climates") do |climates|
        climates.field("region", Wheels::Orm::Types::String.new(200))
        climates.field("climate", Wheels::Orm::Types::String.new(200))

        climates.key(climates["region"])
      end
    end

    @city = Class.new do
      Wheels::Orm::Mappings["default"].map(self, "cities") do |cities|
        cities.field("name", Wheels::Orm::Types::String.new(200))
        cities.field("state", Wheels::Orm::Types::String.new(200))
        cities.field("region", Wheels::Orm::Types::String.new(200))

        cities.key(cities["name"], cities["state"])
      end
    end

    @person = Class.new do
      Wheels::Orm::Mappings["default"].map(self, "people") do |people|
        people.key people.field("id", Wheels::Orm::Types::Serial)
        people.field "name", Wheels::Orm::Types::String.new(200)
        people.field "gpa", Wheels::Orm::Types::Float(7, 2)
      end
    end

    @article = Class.new do
      Wheels::Orm::Mappings["default"].map(self, "articles") do |articles|
        articles.field("id", Wheels::Orm::Types::Serial)
        articles.field("time", Time)
        articles.field("date", Date)
        articles.field("datetime", DateTime)
        articles.key(articles["id"])
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

  def test_support_for_date_and_time_fields
    schema = Wheels::Orm::Schema.new("default")
    assert_nothing_raised { schema.create(@article) }
    assert(schema.exists?(@article))

    article = @article.new

    date = Date.today
    time = Time.now
    datetime = DateTime.now

    article.datetime = datetime
    article.date = date
    article.time = time

    assert_nothing_raised { orm.save(article) }
    assert_not_nil(article.id)

    assert_equal(time.to_s, orm.get(@article, article.id).time.to_s)
    assert_equal(date.to_s, orm.get(@article, article.id).date.to_s)
    assert_equal(datetime.to_s, orm.get(@article, article.id).datetime.to_s)
  ensure
    schema.destroy(@article) rescue nil
  end

  def test_insert_multiple_records
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    person1 = @person.new
    person1.name = "John"

    person2 = @person.new
    person2.name = "Jane"

    people = Wheels::Orm::Collection.new(Wheels::Orm::Mappings["default"].mappings[@person], [person1, person2])

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

  def test_find
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
      people = orm.find(@person, nil, nil)
      assert_equal(2, people.size)
    end

  ensure
    schema.destroy(@person)
  end

  def test_find_with_conditions
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
      low_gpa = Wheels::Orm::Query::Condition.lt(Wheels::Orm::Mappings["default"].mappings[@person]["gpa"], 3)
      people = orm.find(@person, nil, low_gpa)
      assert_equal(1, people.size)
    end

  ensure
    schema.destroy(@person)
  end

  def test_get_with_composite_mapping
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@zoo)
    schema.create(@city)
    schema.create(@climate)

    city = @city.new
    city.name = "Dallas"
    city.state = "Texas"
    city.region = "South"
    orm.save(city)

    zoo = @zoo.new
    zoo.name = "Dallas Zoo"
    zoo.city = "Dallas"
    zoo.state = "Texas"
    orm.save(zoo)

    assert_equal("South", orm.get(@zoo, zoo.id).region)

  ensure
    schema.destroy(@zoo)
    schema.destroy(@city)
    schema.destroy(@climate)
  end

  def test_get_with_multiple_composite_mappings
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@zoo)
    schema.create(@city)
    schema.create(@climate)

    city = @city.new
    city.name = "Dallas"
    city.state = "Texas"
    city.region = "South"
    orm.save(city)

    climate = @climate.new
    climate.region = "South"
    climate.climate = "Hot"
    orm.save(climate)

    zoo = @zoo.new
    zoo.name = "Dallas Zoo"
    zoo.city = "Dallas"
    zoo.state = "Texas"
    orm.save(zoo)

    assert_equal("South", orm.get(@zoo, zoo.id).region)
    assert_equal("Hot", orm.get(@zoo, zoo.id).climate)

  ensure
    schema.destroy(@zoo)
    schema.destroy(@city)
    schema.destroy(@climate)
  end

  def test_all_with_single_condition
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    bob = @person.new
    bob.name = "Bob"
    bob.gpa = 4.0
    orm.save(bob)

    assert_nothing_raised do
      people = orm.all(@person) { |person| person.name.eq("Bob") }
      assert_equal(1, people.size)
    end
  ensure
    schema.destroy(@person)
  end

  def test_all_with_multiple_conditions
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    jimmy = @person.new
    jimmy.name = "Jimmy"
    jimmy.gpa = 3.5
    orm.save(jimmy)

    assert_nothing_raised do
      people = orm.all(@person) do |person|
        person.gpa.gt(3).or(person.name.eq("Jimmy"))
      end

      assert_equal(1, people.size)
    end
  ensure
    schema.destroy(@person)
  end

  def test_all_with_limit_and_order
    schema = Wheels::Orm::Schema.new("default")
    schema.create(@person)

    mike = @person.new
    mike.name = "Mike"
    mike.gpa = 1.2
    orm.save(mike)

    scott = @person.new
    scott.name = "Scott"
    scott.gpa = 4.0
    orm.save(scott)

    bernerd = @person.new
    bernerd.name = "Bernerd"
    bernerd.gpa = 3.6
    orm.save(bernerd)

    sam = @person.new
    sam.name = "Sam"
    sam.gpa = 0.1
    orm.save(sam)

    assert_equal(4, orm.all(@person).size)

    assert_nothing_raised do
      people = orm.all(@person) do |person|
        person.limit 3
        person.order(person.gpa.desc, person.name)
      end

      assert_equal(3, people.size)
      assert_equal('%1.1f' % [scott.gpa],     '%1.1f' % [people[0].gpa])
      assert_equal('%1.1f' % [bernerd.gpa],   '%1.1f' % [people[1].gpa])
      assert_equal('%1.1f' % [mike.gpa],      '%1.1f' % [people[2].gpa])
    end
  ensure
    schema.destroy(@person)
  end
end