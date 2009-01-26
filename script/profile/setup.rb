Wheels::Orm::Repositories.register("default", "jdbc:hsqldb:mem:test")

TIMES = (ENV["x"] || 1000).to_i

class Person
  orm.map(self, "people") do |people|
    people.key people.field("id", Wheels::Orm::Types::Serial)
    people.field("name", String)
    people.field("gpa", Float)
  end
end

schema = Wheels::Orm::Schema.new("default")
schema.create(Person)

case ENV["TARGET"]
when "get", "all"
  people = Wheels::Orm::Collection.new(orm.mappings[Person], (1..1000).map do
    person = Person.new
    person.name = "John Doe"
    person.gpa = "#{rand(4)}.#{rand(9)}".to_f
    person
  end)
  orm.create(people)
end