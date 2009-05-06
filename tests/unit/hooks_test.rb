require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class HooksTest < Test::Unit::TestCase

  class Hooked
    include Beacon::Hooks

    attr_accessor :before_hook_calls, :after_hook_calls, :hooked_method_calls
    attr_accessor :before_hook_with_args_calls, :after_with_args_hook_calls, :hooked_method_with_args_calls

    def initialize
      @before_hook_calls = 0
      @after_hook_calls = 0
      @hooked_method_calls = 0

      @before_hook_with_args_calls = 0
      @after_hook_with_args_calls = 0
      @hooked_method_with_args_calls = 0
    end

    def hooked_method
      @hooked_method_calls += 1
    end

    before :hooked_method do |reciever|
      reciever.before_hook_calls += 1
    end

    after :hooked_method do |reciever|
      reciever.after_hook_calls += 1
    end

    def hooked_method_with_args(color, size)
      @hooked_method_with_args_calls += 1
    end

    before :hooked_method_with_args do |reciever|
      reciever.before_hook_with_args_calls += 1
    end

    after :hooked_method_with_args do |reciever|
      reciever.after_hook_with_args_calls += 1
    end
  end

  def setup
  end

  def test_before_hooks_register_class_method
    assert_respond_to(Hooked, :before)
  end

  def test_before_and_after_hook_firing
    hooked_instance = Hooked.new

    assert_equal(0, hooked_instance.before_hook_calls)
    assert_equal(0, hooked_instance.hooked_method_calls)
    assert_equal(0, hooked_instance.after_hook_calls)

    hooked_instance.hooked_method

    assert_equal(1, hooked_instance.before_hook_calls)
    assert_equal(1, hooked_instance.hooked_method_calls)
    assert_equal(1, hooked_instance.after_hook_calls)
  end

  def test_after_hooks_register_class_method
    assert_respond_to(Hooked, :after)
  end

  def test_can_define_hooks_before_method_added
  end

  def test_hooked_methods_should_preserve_arguments
  end

end