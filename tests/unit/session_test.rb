require "helper"

class SessionTest < Test::Unit::TestCase
    
  def test_can_initialize_a_session
    assert_nothing_raised do
      Wheels::Orm::Session.new("default")
    end
  end
  
  def test_has_a_repository
    Wheels::Orm::Mappings["default"]
    
    
    # assert_kind_of(Wheels::Orm::Repositories::Abstract)
    # Except that the Repository is driver-specific. It's our Adapter.
    # So we can't initialize it generically. So the URI is required.
    # Which means a connection URI is required to define your mappings.
    # Which isn't in itself terrible since the idea is to write/test your class
    # without persistence in mind. But then again, it means methods that might
    # be lazy, return embedded-values or Collections aren't testable without
    # defining your mappings first, which again, can't be done without a
    # database connection. Icky.
    #
    # So OK, we assume the mapped types are generic O/RM featured types and
    # not repository specific types. That sort of works... maybe.
  end
end