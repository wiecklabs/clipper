module Wheels
  module Orm
    module Mappings
      class Field
        
        include Test::Unit::Assertions
        
        def initialize(name, type)
          assert_kind_of(String, name, "Field#name must be a String")
          assert(!Helpers::blank?(name), "Field#name must not be blank")
          @name = name
          
          assert_kind_of(Class, type, "Field#type must be a Class")
          @type = type
        end
        
        def name
          @name
        end
        
        def type
          @type
        end
      end
    end
  end
end