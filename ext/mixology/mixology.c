#include "ruby.h"

static void remove_nested_module(VALUE klass, VALUE include_class) {

	 if(RBASIC(RCLASS(klass)->super)->klass != RBASIC(RCLASS(include_class)->super)->klass) {
	  	return;
	 }
	if(RCLASS(RCLASS(include_class)->super)->super && BUILTIN_TYPE(RCLASS(include_class)->super) == T_ICLASS) {
		remove_nested_module(RCLASS(klass)->super, RCLASS(include_class)->super);
  }
       RCLASS(klass)->super = RCLASS(RCLASS(klass)->super)->super;
}

static VALUE rb_unmix(VALUE self, VALUE module) {
	VALUE klass;
  for (klass = RBASIC(self)->klass; klass != rb_class_real(klass); klass = RCLASS(klass)->super) {
   VALUE super = RCLASS(klass)->super;
   if (BUILTIN_TYPE(super) == T_ICLASS) {
  		if (RBASIC(super)->klass == module) {
			  if(RCLASS(module)->super && BUILTIN_TYPE(RCLASS(module)->super) == T_ICLASS)
					remove_nested_module(super, module);
       	RCLASS(klass)->super = RCLASS(RCLASS(klass)->super)->super;
       	rb_clear_cache();
     }
   }
  }
  return self;
}

static void add_module(VALUE self, VALUE module) {
		VALUE super = RCLASS(rb_singleton_class(self))->super;
  NEWOBJ(klass, struct RClass);
  OBJSETUP(klass, rb_cClass, T_ICLASS);

  if (BUILTIN_TYPE(module) == T_ICLASS) {
   module = RBASIC(module)->klass;
  }
  if (!RCLASS(module)->iv_tbl) {
  	RCLASS(module)->iv_tbl = (void*)st_init_numtable();
  }
  klass->iv_tbl = RCLASS(module)->iv_tbl;
  klass->m_tbl = RCLASS(module)->m_tbl;
  klass->super = super;
  if (TYPE(module) == T_ICLASS) {
   RBASIC(klass)->klass = RBASIC(module)->klass;
  }
  else {
   RBASIC(klass)->klass = module;
  }
  OBJ_INFECT(klass, module);
  OBJ_INFECT(klass, super);

  RCLASS(rb_singleton_class(self))->super = (int)klass;

}

static VALUE rb_mixin(VALUE self, VALUE module) {
	VALUE nested_modules;
	VALUE nested_module;
	int index;
	rb_unmix(self, module);

  nested_modules = rb_mod_included_modules(module);
  //VALUE nested_modules = rb_mod_included_modules(module);
  for (index = RARRAY(nested_modules)->len; index > 0; index--) {
     nested_module = RARRAY(nested_modules)->ptr[index-1];
      add_module(self, nested_module);
  }

	add_module(self, module);

  rb_clear_cache();
	return self;
}

	void Init_mixology() {
	  VALUE Mixology = rb_define_module("Mixology");
	  rb_define_method(Mixology, "mixin", rb_mixin, 1);
	  rb_define_method(Mixology, "unmix", rb_unmix, 1);
	  rb_include_module(rb_cObject, Mixology);
	}
