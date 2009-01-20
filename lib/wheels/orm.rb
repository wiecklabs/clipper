require "pathname"
require "set"
require "test/unit"
require "rubygems"

require Pathname(__FILE__).dirname.parent + "wieck" + "assertions"
require Pathname(__FILE__).dirname.parent + "wieck" + "blank"
require Pathname(__FILE__).dirname.parent + "wieck" + "ordered_set"
require Pathname(__FILE__).dirname.parent + "wieck" + "string"

require Pathname(__FILE__).dirname + "orm" + "uri"

require Pathname(__FILE__).dirname + "orm" + "type"
require Pathname(__FILE__).dirname + "orm" + "types"
require Pathname(__FILE__).dirname + "orm" + "mappings" + "mapping"
require Pathname(__FILE__).dirname + "orm" + "mappings" + "relation"
require Pathname(__FILE__).dirname + "orm" + "mappings" + "composite_mapping"

require Pathname(__FILE__).dirname + "orm" + "repositories"
require Pathname(__FILE__).dirname + "orm" + "repositories" + "schema"
require Pathname(__FILE__).dirname + "orm" + "repositories" + "abstract"

require Pathname(__FILE__).dirname + "orm" + "session"
require Pathname(__FILE__).dirname + "orm" + "collection"
require Pathname(__FILE__).dirname + "orm" + "identity_map"
require Pathname(__FILE__).dirname + "orm" + "mappings"
require Pathname(__FILE__).dirname + "orm" + "schema"

def orm(name = "default")
  session = Wheels::Orm::Session.new(name)
  yield session if block_given?
  session
end