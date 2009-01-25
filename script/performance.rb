require 'benchmark'
require 'pathname'
require 'rubygems'

ORM = ARGV.first || "worm"

if ORM == "dm"
  gem "dm-core"
  require "dm-core"
else
  require Pathname(__FILE__).dirname.parent + "lib" + "wheels" + "orm"
end

gem 'faker', '~>0.3.1'
require 'faker'

if ORM == "dm"
  class Person
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    property :gpa, Float
  end

  DataMapper.setup(:default, "sqlite3:///tmp/dm_sqlite.db")
  Person.auto_migrate!
else

  Wheels::Orm::Repositories.register("default", "jdbc:hsqldb:mem:test")

  class Person
    orm.map(self, "people") do |people|
      people.key people.field("id", Wheels::Orm::Types::Serial)
      people.field("name", String)
      people.field("gpa", Float)
    end
  end

  schema = Wheels::Orm::Schema.new("default")
  schema.destroy(Person) rescue nil
  schema.create(Person)
end

TIMES = ENV['x'] ? ENV['x'].to_i : 1000

puts "You can specify how many times you want to run the benchmarks with rake:perf x=(number)"
puts "Some tasks will be run 10 and 1000 times less than (number)"
puts "Benchmarks will now run #{TIMES} times"

session = orm

Benchmark.bmbm do |x|
  x.report("create") do
    people = (1..TIMES).map do
      person = Person.new
      person.name = Faker::Name.name
      person.gpa = "#{rand(4)}.#{rand(9)}".to_f
      person
    end

    if ORM == "dm"
      repository.create(people)
    else
      session.save(Wheels::Orm::Collection.new(session.mappings[Person], people))
    end
  end

  x.report("get") do
    (1..TIMES).each do |i|
      ORM == "dm" ? Person.get(i) : session.get(Person, i)
    end
  end

  x.report("all") do
    1.upto(TIMES / 10) { ORM == "dm" ? Person.all.entries : session.all(Person) }
  end
end