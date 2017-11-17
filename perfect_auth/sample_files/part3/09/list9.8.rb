# coding: utf-8

class SuperKlass
  def super_method
    self.class
  end
end

class Klass < SuperKlass
end

class NotInheritKlass
  def super_method
    self.class
  end
end

super_klass = SuperKlass.new
klass = Klass.new
not_inherit_klass = NotInheritKlass.new

# SuperKlass#super_methodのUnboundMethodオブジェクトを生成
unbind_super_method = SuperKlass.instance_method(:super_method)

# bindするオブジェクトが同じクラスのインスタンスなので実行される
unbind_super_method.bind(super_klass).call
  # => SuperKlass

# bindするオブジェクトがサブクラスのインスタンスなので実行される
unbind_super_method.bind(klass).call
  # => Klass

# bindするオブジェクトが同名のメソッドを持っていてもSuperKlassのサブクラスでないのでTypeError
unbind_super_method.bind(not_inherit_klass).call
  # => :in `bind': bind argument must be an instance of SuperKlass (TypeError)
