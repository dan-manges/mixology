#include "ruby.h"

/* cannot use ordinary CLASS_OF as it does not return an lvalue */
#define KLASS_OF(c) (RBASIC(c)->klass)

/* macros for backwards compatibility with 1.8 */
#ifndef RUBY_19
# define RCLASS_M_TBL(c) (RCLASS(c)->m_tbl)
# define RCLASS_SUPER(c) (RCLASS(c)->super)
# define RCLASS_IV_TBL(c) (RCLASS(c)->iv_tbl)
#endif

#ifdef RUBY_19
static VALUE class_alloc(VALUE flags, VALUE klass)
{
    rb_classext_t *ext = ALLOC(rb_classext_t);
    NEWOBJ(obj, struct RClass);
    OBJSETUP(obj, klass, flags);
    obj->ptr = ext;
    RCLASS_IV_TBL(obj) = 0;
    RCLASS_M_TBL(obj) = 0;
    RCLASS_SUPER(obj) = 0;
    RCLASS_IV_INDEX_TBL(obj) = 0;
    return (VALUE)obj;
}
#endif

static void remove_nested_module(VALUE klass, VALUE include_class)
{
    if (KLASS_OF(RCLASS_SUPER(klass)) != KLASS_OF(RCLASS_SUPER(include_class))) {
        return;
    }
    if (RCLASS_SUPER(RCLASS_SUPER(include_class)) && BUILTIN_TYPE(RCLASS_SUPER(include_class)) == T_ICLASS) {
        remove_nested_module(RCLASS_SUPER(klass), RCLASS_SUPER(include_class));
    }
    RCLASS_SUPER(klass) = RCLASS_SUPER(RCLASS_SUPER(klass));
}

static VALUE rb_unmix(VALUE self, VALUE module)
{
    VALUE klass;

    /* check that module is valid */
    if (TYPE(module) != T_MODULE)
        rb_raise(rb_eArgError, "error: parameter must be a module");

    for (klass = KLASS_OF(self); klass != rb_class_real(klass); klass = RCLASS_SUPER(klass)) {
        VALUE super = RCLASS_SUPER(klass);
        if (BUILTIN_TYPE(super) == T_ICLASS) {
            if (KLASS_OF(super) == module) {
                if (RCLASS_SUPER(module) && BUILTIN_TYPE(RCLASS_SUPER(module)) == T_ICLASS)
                    remove_nested_module(super, module);

                RCLASS_SUPER(klass) = RCLASS_SUPER(RCLASS_SUPER(klass));
                rb_clear_cache();
            }
        }
    }
    return self;
}

static void add_module(VALUE self, VALUE module)
{
    VALUE super = RCLASS_SUPER(rb_singleton_class(self));

#ifdef RUBY_19
    VALUE klass = class_alloc(T_ICLASS, rb_cClass);
#else
    NEWOBJ(klass, struct RClass);
    OBJSETUP(klass, rb_cClass, T_ICLASS);
#endif

    if (BUILTIN_TYPE(module) == T_ICLASS) {
        module = KLASS_OF(module);
    }
    if (!RCLASS_IV_TBL(module)) {
        RCLASS_IV_TBL(module) = (void*)st_init_numtable();
    }

    RCLASS_IV_TBL(klass) = RCLASS_IV_TBL(module);
    RCLASS_M_TBL(klass) = RCLASS_M_TBL(module);
    RCLASS_SUPER(klass) = super;

    if (TYPE(module) == T_ICLASS) {
        KLASS_OF(klass) = KLASS_OF(module);
    } else {
        KLASS_OF(klass) = module;
    }
    OBJ_INFECT(klass, module);
    OBJ_INFECT(klass, super);

    RCLASS_SUPER(rb_singleton_class(self)) = (VALUE)klass;
}

static VALUE rb_mixin(VALUE self, VALUE module)
{
    VALUE nested_modules;
    int index;

    /* check that module is valid */
    if (TYPE(module) != T_MODULE)
        rb_raise(rb_eArgError, "error: parameter must be a module");

    rb_unmix(self, module);
    nested_modules = rb_mod_included_modules(module);

    for (index = RARRAY_LEN(nested_modules); index > 0; index--) {
        VALUE nested_module = RARRAY_PTR(nested_modules)[index - 1];
        add_module(self, nested_module);
    }

    add_module(self, module);

    rb_clear_cache();
    return self;
}

void Init_mixology()
{
    VALUE Mixology = rb_define_module("Mixology");

    rb_define_method(Mixology, "mixin", rb_mixin, 1);
    rb_define_method(Mixology, "unmix", rb_unmix, 1);
    rb_include_module(rb_cObject, Mixology);
}
