require File.dirname(__FILE__) + "/test_helper"

class MixologyTest < Test::Unit::TestCase
  
  test "mixin" do
    mixin = Module.new { def foo; "foo"; end }
    object = Object.new
    object.mixin mixin
    assert_equal "foo", object.foo
  end
  
  test "unmix" do
    mixin = Module.new { def foo; "mixin"; end }
    object = Class.new { def foo; "object"; end }.new
    object.mixin mixin
    assert_equal "mixin", object.foo
    object.unmix mixin
    assert_equal "object", object.foo
  end
  
  test "mixin twice" do
    first_mixin = Module.new { def foo; "first"; end }
    second_mixin = Module.new { def foo; "second"; end }
    object = Object.new
    object.mixin first_mixin
    object.mixin second_mixin
    assert_equal "second", object.foo
  end
  
  test "mixin to class" do
    mix = Module.new { def foo; "foo"; end }
    klass = Class.new { mixin mix }
    assert_equal "foo", klass.foo
  end
  
  test "can mixin again" do
    first_mixin = Module.new { def foo; "first"; end }
    second_mixin = Module.new { def foo; "second"; end }
    object = Object.new
    object.mixin first_mixin
    object.mixin second_mixin
    object.mixin first_mixin
    assert_equal "first", object.foo
  end
  
  test "unmix effects limited to instance" do
    mixin = Module.new { def foo; "mixin"; end }
    object = Class.new {include mixin}.new
    assert_equal "mixin", object.foo
    object.unmix mixin
    assert_equal "mixin", object.foo
  end
  
  test "can add mod to an instance even when already included by class" do
    mixin = Module.new { def foo; "mixin"; end }
    klass = Class.new {include mixin; def foo; "class"; end }
    object = klass.new
    assert_equal "class", object.foo
    object.mixin mixin
    assert_equal "mixin", object.foo
  end
  
  test "included modules after mixin" do
    mixin = Module.new
    object = Object.new
    object.mixin mixin
    assert_equal [mixin, Mixology, Kernel], (class << object; self; end).included_modules
  end
  
  test "included modules after unmix" do
    mixin = Module.new
    object = Object.new
    object.mixin mixin
    object.unmix mixin
    assert_equal [Mixology, Kernel], (class << object; self; end).included_modules
  end
  
  test "included modules after remix" do
    mixin_one = Module.new
    mixin_two = Module.new
    object = Object.new
    object.mixin mixin_one
    object.mixin mixin_two
    assert_equal [mixin_two, mixin_one, Mixology, Kernel], (class << object; self; end).included_modules
    object.mixin mixin_one
    assert_equal [mixin_one, mixin_two, Mixology, Kernel], (class << object; self; end).included_modules
  end
  
  test "mixin returns object" do
    object = Object.new
    mixin = Module.new
    assert_equal object, object.mixin(mixin)
  end
  
  test "unmix returns object" do
    object = Object.new
    mixin = Module.new
    object.mixin mixin
    assert_equal object, object.unmix(mixin)
  end
  
  test "nested modules are mixedin" do
    nested_module = Module.new { def foo; "foo"; end }
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin mixin
    assert_equal [mixin, nested_module, Mixology, Kernel], (class << object; self; end).included_modules
  end
   
  test "nested modules are mixedin even if alrady mixed in" do
    nested_module = Module.new { def foo; "foo"; end }
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin nested_module
    object.mixin mixin
    assert_equal [mixin, nested_module, nested_module, Mixology, Kernel], (class << object; self; end).included_modules
  end
  
  test "module is not unmixed if it is outside nested chain" do
    nested_module = Module.new
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin nested_module
    object.mixin mixin
    object.unmix mixin
    assert_equal [nested_module, Mixology, Kernel], (class << object; self; end).included_modules
  end
  
  test "nested modules are unmixed" do
    nested_module = Module.new
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin mixin
    object.unmix mixin
    assert_equal [Mixology, Kernel], (class << object; self; end).included_modules
  end
  
  test "nested modules are unmixed deeply" do
    nested_module_ultimate = Module.new
    nested_module_penultimate = Module.new { include nested_module_ultimate }
    nested_module = Module.new { include nested_module_penultimate }
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin mixin
    object.unmix mixin
    assert_equal [Mixology, Kernel], (class << object; self; end).included_modules
  end

  test "unrelated modules are not unmixed" do
    unrelated = Module.new
    nested_module = Module.new 
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin unrelated
    object.mixin mixin
    object.unmix mixin
    assert_equal [unrelated, Mixology, Kernel], (class << object; self; end).included_modules
  end

end
