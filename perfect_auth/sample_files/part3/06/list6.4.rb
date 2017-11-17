# coding: utf-8

class Klass
  # クラスインスタンス変数の初期化
  # ただし、この方法では継承された時サブクラスでは初期化されていない
  @class_instance_val = :class_instance_val

  def instance_method
    self.class.instance_variable_get :@class_instance_val #=> :class_instance_val
  end
end
