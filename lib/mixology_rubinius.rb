module Mixology
  def mixin(mod)
    unmix mod
    reset_method_cache
    IncludedModule.new(mod).attach_to metaclass
    reset_method_cache
    self
  end
  
  def unmix(mod_to_unmix)
    last_super = metaclass
    this_super = metaclass.direct_superclass
    while this_super
      break if this_super == self.class
      if (this_super == mod_to_unmix ||
          this_super.respond_to?(:module) && this_super.module == mod_to_unmix)
        reset_method_cache
        last_super.superclass = this_super.direct_superclass
        reset_method_cache
        return self
      else
        last_super = this_super
        this_super = this_super.direct_superclass
      end
    end
    self
  end
  
  protected
  
  def reset_method_cache
    self.methods.each do |name|
      name = self.metaclass.send(:normalize_name,name)
      Rubinius::VM.reset_method_cache(name)
    end
  end
end

Object.send :include, Mixology
