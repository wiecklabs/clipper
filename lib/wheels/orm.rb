require "pathname"
require "set"

require "rubygems"

gem "helpers"
require "helpers"

require "test/unit"
require Pathname(__FILE__).dirname.parent + "assertions"

require Pathname(__FILE__).dirname + "orm" + "type"
require Pathname(__FILE__).dirname + "orm" + "types"
require Pathname(__FILE__).dirname + "orm" + "mappings" + "mapping"
require Pathname(__FILE__).dirname + "orm" + "adapters" + "abstract"