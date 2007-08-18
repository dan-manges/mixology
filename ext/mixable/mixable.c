#include "ruby.h"

static void rb_unmix(VALUE self, VALUE module) {
  VALUE klass;
  for (klass = RBASIC(self)->klass; klass != rb_class_real(klass); klass = RCLASS(klass)->super) {
   VALUE super = RCLASS(klass)->super;
   if (BUILTIN_TYPE(super) == T_ICLASS) {
  		if (RBASIC(super)->klass == module) {
       RCLASS(klass)->super = RCLASS(super)->super;
       rb_clear_cache();
     }
   }
  }
}

static void rb_mixin(VALUE self, VALUE module) {
  
	rb_unmix(self, module);

	VALUE super = RCLASS(rb_singleton_class(self))->super;
  NEWOBJ(klass, struct RClass);
  OBJSETUP(klass, rb_cClass, T_ICLASS);

  if (BUILTIN_TYPE(module) == T_ICLASS) {
   module = RBASIC(module)->klass;
  }
  if (!RCLASS(module)->iv_tbl) {
  	RCLASS(module)->iv_tbl = st_init_numtable();
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

  RCLASS(rb_singleton_class(self))->super = klass;
  rb_clear_cache();
  }

	void Init_mixable() {
	  VALUE Mixable = rb_define_module("Mixable");
	  rb_define_method(Mixable, "mixin", rb_mixin, 1);
	  rb_define_method(Mixable, "unmix", rb_unmix, 1);
	  rb_include_module(rb_cObject, Mixable);

	}
	