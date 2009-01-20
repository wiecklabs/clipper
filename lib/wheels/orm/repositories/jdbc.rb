module Wheels
  module Orm
    module Repositories
      class Jdbc
        autoload :Sqlite, (Pathname(__FILE__).dirname + "jdbc" + "sqlite.rb").to_s
      end
    end
  end
end