require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class RepositoryTest < Test::Unit::TestCase
  def setup
    @uri = Clipper::Uri.new("abstract://localhost/example")
  end


end