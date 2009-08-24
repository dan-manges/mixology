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
  
  def test_included_modules_after_mixin
    mixin = Module.new
    object = Object.new
    object.mixin mixin
    assert_equal [mixin, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
  
  def test_included_modules_after_unmix
    mixin = Module.new
    object = Object.new
    object.mixin mixin
    object.unmix mixin
    assert_equal [Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
  
  def test_included_modules_after_remix
    mixin_one = Module.new
    mixin_two = Module.new
    object = Object.new
    object.mixin mixin_one
    object.mixin mixin_two
    assert_equal [mixin_two, mixin_one, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
    object.mixin mixin_one
    assert_equal [mixin_one, mixin_two, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
  
  def test_mixin_returns_object
    object = Object.new
    mixin = Module.new
    assert_equal object, object.mixin(mixin)
  end
  
  def test_unmix_returns_object
    object = Object.new
    mixin = Module.new
    object.mixin mixin
    assert_equal object, object.unmix(mixin)
  end
  
  def test_nested_modules_are_mixedin
    if rubinius?
      print "PENDING"; return
    end
    nested_module = Module.new { def foo; "foo"; end }
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin mixin
    assert_equal [mixin, nested_module, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end

  def test_nested_modules_are_mixedin_deeply
    if rubinius?
      print "PENDING"; return
    end
    nested_module_ultimate = Module.new
    nested_module_penultimate = Module.new { include nested_module_ultimate }
    nested_module = Module.new { include nested_module_penultimate }
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin mixin
    assert_equal [mixin, nested_module, nested_module_penultimate, nested_module_ultimate, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
   
  def test_nested_modules_are_mixedin_even_if_already_mixed_in
    if rubinius?
      print "PENDING"; return
    end
    nested_module = Module.new { def foo; "foo"; end }
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin nested_module
    object.mixin mixin
    assert_equal [mixin, nested_module, nested_module, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
  
  def test_module_is_not_unmixed_if_it_is_outside_nested_chain
    nested_module = Module.new
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin nested_module
    object.mixin mixin
    object.unmix mixin
    assert_equal [nested_module, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
  
  def test_nested_modules_are_unmixed
    nested_module = Module.new
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin mixin
    object.unmix mixin
    assert_equal [Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
  
  def test_nested_modules_are_unmixed_deeply
    nested_module_ultimate = Module.new
    nested_module_penultimate = Module.new { include nested_module_ultimate }
    nested_module = Module.new { include nested_module_penultimate }
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin mixin
    object.unmix mixin
    assert_equal [Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end

  def test_unrelated_modules_are_not_unmixed
    unrelated = Module.new
    nested_module = Module.new 
    mixin = Module.new { include nested_module }
    object = Object.new
    object.mixin unrelated
    object.mixin mixin
    object.unmix mixin
    assert_equal [unrelated, Mixology, PP::ObjectMixin, Kernel], (class << object; self; end).included_modules
  end
  
  def rubinius?
    defined?(RUBY_ENGINE) && RUBY_ENGINE == "rbx"
  end

end
