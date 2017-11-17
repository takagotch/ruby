#include "c_ext_sample_pruby.h"

VALUE rb_mCExtSamplePruby;

static VALUE
print_hello(VALUE self)
{
  return rb_str_new2("hello pruby!! from c ext");
}

static VALUE
hello_to(VALUE self, VALUE s_ruby)
{
  char* string_from_ruby;
  string_from_ruby = StringValuePtr(s_ruby);
  return rb_str_cat_cstr(rb_str_new2("say hello to "), string_from_ruby);
}

void
Init_c_ext_sample_pruby(void)
{
  rb_mCExtSamplePruby = rb_define_module("CExtSamplePruby");
  rb_define_singleton_method(rb_mCExtSamplePruby, "c_ext_hello", print_hello, 0);
  rb_define_singleton_method(rb_mCExtSamplePruby, "c_ext_hello_to", hello_to, 1);
}
