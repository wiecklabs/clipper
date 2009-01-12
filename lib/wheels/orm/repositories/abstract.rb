module Wheels
  module Orm
    module Repositories
      class Abstract
        
        # Repository Types should handle coersion (in both directions) of values
        # from repository storage to object storage.
        module Types
          
          class String < Type
          end
          
          class Integer < Type
          end
        end
      end
    end
  end
end