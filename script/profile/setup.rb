Clipper::open("default", "jdbc:hsqldb:mem:test")

TIMES = (ENV["x"] || 1000).to_i

class Person
  Clipper::Mappings["default"].map(self, "people") do |people|
    people.key people.field("id", Clipper::Types::Serial)
    people.field("name", String)
    people.field("gpa", Clipper::Types::Float(7, 2))
  end
end

schema = Clipper::Schema.new("default")
schema.create(Person)

case ENV["TARGET"]
when "get", "all"
  people = Clipper::Collection.new(Clipper::Mappings["default"].mappings[Person], (1..1000).map do
    person = Person.new
    person.name = "John Doe"
    person.gpa = "#{rand(4)}.#{rand(9)}".to_f
    person
  end)
  orm.create(people)
end