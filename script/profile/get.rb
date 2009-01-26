require File.dirname(__FILE__) + "/setup"
require "profile"

orm do |session|
  TIMES.times do
    session.get(Person, 1)
  end
end