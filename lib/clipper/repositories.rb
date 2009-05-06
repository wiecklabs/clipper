module Clipper
  module Repositories

    autoload :Jdbc, (Pathname(__FILE__).dirname + "repositories" + "jdbc.rb").to_s

  end # module Repositories
end # module Clipper