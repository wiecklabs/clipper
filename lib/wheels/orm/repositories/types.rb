module Wheels
  module Orm
    module Repositories
         
      # Repository Types should handle coersion (in both directions) of values
      # from repository storage to object storage.
      module Types
        
        class String < Wheels::Orm::Type
        end
        
        class Integer < Wheels::Orm::Type
        end
      end # module Types
    end # module Repositories
  end # module Orm
end # module Wheels