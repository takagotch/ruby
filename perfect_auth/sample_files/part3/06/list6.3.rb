# coding: utf-8

class Klass
  @class_instance_val = :class_instance_val
  @@class_val = :class_val

  def instance_method
    # クラスインスタンス変数へのアクセスとは見做されずインスタンス変数へのアクセスとされる
    @class_instance_val #=> nil

    # クラス変数へはアクセス可能
    @@class_val #=> :class_val
  end
end
