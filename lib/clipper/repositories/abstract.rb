require Pathname(__FILE__).dirname + "type"

module Clipper
  module Repositories

    ##
    # Abstract repository class to match "abstract://" scheme.
    ##
    class Abstract < Clipper::Repository
    end # class Abstract

  end # module Repositories
end