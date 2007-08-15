require File.dirname(__FILE__) + "/test_helper"

class MixologyTest < Test::Unit::TestCase

  def test_mixin
    mixin = Module.new { def foo; "foo"; end }
    object = Object.new
    object.mixin mixin
    assert_equal "foo", object.foo
  end
  
  def test_unmix
    mixin = Module.new { def foo; "mixin"; end }
    object = Class.new { def foo; "object"; end }.new
    object.mixin mixin
    assert_equal "mixin", object.foo
    object.unmix mixin
    assert_equal "object", object.foo
  end
  
  def test_mixin_twice
    first_mixin = Module.new { def foo; "first"; end }
    second_mixin = Module.new { def foo; "second"; end }
    object = Object.new
    object.mixin first_mixin
    object.mixin second_mixin
    assert_equal "second", object.foo
  end
  
  def test_mixin_to_class
    mix = Module.new { def foo; "foo"; end }
    klass = Class.new { mixin mix }
    assert_equal "foo", klass.foo
  end
  
  def test_can_mixin_again
    first_mixin = Module.new { def foo; "first"; end }
    second_mixin = Module.new { def foo; "second"; end }
    object = Object.new
    object.mixin first_mixin
    object.mixin second_mixin
    object.mixin first_mixin
    assert_equal "first", object.foo
  end
  
  def test_unmix_effects_limited_to_instance
    mixin = Module.new { def foo; "mixin"; end }
    object = Class.new {include mixin}.new
    assert_equal "mixin", object.foo
    object.unmix mixin
    assert_equal "mixin", object.foo
  end
  
  def test_can_add_mod_to_an_instance_even_when_already_included_by_class
    mixin = Module.new { def foo; "mixin"; end }
    klass = Class.new {include mixin; def foo; "class"; end }
    object = klass.new
    assert_equal "class", object.foo
    object.mixin mixin
    assert_equal "mixin", object.foo
  end

end
