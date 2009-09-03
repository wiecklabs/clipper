module Clipper
  module Repositories
    module Types
      autoload :Abstract, (Pathname(__FILE__).dirname + "abstract.rb").to_s
      autoload :Hsqldb, (Pathname(__FILE__).dirname + "hsqldb.rb").to_s
      autoload :Mysql, (Pathname(__FILE__).dirname + "mysql.rb").to_s
    end
  end
end