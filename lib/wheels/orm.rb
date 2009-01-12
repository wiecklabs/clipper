require "pathname"
require "set"
require "test/unit"

require Pathname(__FILE__).dirname.parent + "wieck" + "assertions"
require Pathname(__FILE__).dirname.parent + "wieck" + "blank"
require Pathname(__FILE__).dirname.parent + "wieck" + "ordered_set"

require Pathname(__FILE__).dirname + "orm" + "type"
require Pathname(__FILE__).dirname + "orm" + "types"
require Pathname(__FILE__).dirname + "orm" + "mappings" + "source"
require Pathname(__FILE__).dirname + "orm" + "mappings" + "relation"

require Pathname(__FILE__).dirname + "orm" + "repositories" + "abstract"