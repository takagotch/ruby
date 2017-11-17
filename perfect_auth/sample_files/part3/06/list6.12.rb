# coding: utf-8

class UnIncludedClass
  def un_included_class_method
    :un_included_class_method
  end
end

class Klass
  define_method :un_included_class_method, UnIncludedClass.instance_method(:un_included_class_method)
end
#=> TypeError: bind argument must be a subclass of UnIncludedClass
