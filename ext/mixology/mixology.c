#include "ruby.h"

/* copied and pasted from class.c rb_include_module */
static VALUE rb_already_included(VALUE klass, VALUE module) {
	int superclass_seen = Qfalse;
  VALUE p, c;
  c = klass;
	if (RCLASS(klass)->m_tbl == RCLASS(module)->m_tbl)
	    rb_raise(rb_eArgError, "cyclic include detected");
	for (p = RCLASS(klass)->super; p; p = RCLASS(p)->super) {
	    switch (BUILTIN_TYPE(p)) {
	      case T_ICLASS:
		      if (RCLASS(p)->m_tbl == RCLASS(module)->m_tbl) {
		        if (!superclass_seen) {
			        c = p;	/* move insertion point */
		        }
		        goto skip;
		      }
		    break;
	      case T_CLASS:
		      superclass_seen = Qtrue;
		      break;
	    }
	}
	skip:
  return superclass_seen;
}

static VALUE rb_unmix(VALUE self, VALUE module) {
  VALUE nested_modules = rb_mod_included_modules(module);
  int index;
  for (index = 0; index < RARRAY(nested_modules)->len; index++) {
    VALUE nested_module = RARRAY(nested_modules)->ptr[index];
    if (rb_already_included(self, nested_module)) {
      rb_unmix(self, nested_module);
    }
  }

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
  return self;
}

static VALUE rb_mixin(VALUE self, VALUE module) {
	rb_unmix(self, module);

  VALUE nested_modules = rb_mod_included_modules(module);
  int index;
  for (index = 0; index < RARRAY(nested_modules)->len; index++) {
    VALUE nested_module = RARRAY(nested_modules)->ptr[index];
    if (!rb_already_included(self, nested_module)) {
      rb_mixin(self, nested_module);
    }
  }

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
  rb_clear_cache();
	return self;
}

	void Init_mixology() {
	  VALUE Mixology = rb_define_module("Mixology");
	  rb_define_method(Mixology, "mixin", rb_mixin, 1);
	  rb_define_method(Mixology, "unmix", rb_unmix, 1);
	  rb_include_module(rb_cObject, Mixology);
	}
