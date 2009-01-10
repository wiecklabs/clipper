module Wheels
  module Orm
    module Mappings
      class Field
        
        include Test::Unit::Assertions
        
        def initialize(name, type)
          begin
            assert_kind_of(String, name, "Field#name must be a String")
            assert(!name.blank?, "Field#name must not be blank")
            @name = name
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end
          
          begin
            assert_descendant_of(Wheels::Orm::Type, type, "Field#type must be a Wheels::Orm::Type")
            @type = type
          rescue Test::Unit::AssertionFailedError => e
            raise ArgumentError.new(e.message)
          end
        end
        
        def name
          @name
        end
        
        def type
          @type
        end
        
        def eql?(other)
          other.is_a?(Field) && type == other.type && name == other.name
        end
        
        def hash
          @hash ||= [name, type].hash
        end
      end
    end
  end
end