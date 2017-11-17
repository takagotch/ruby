# coding: utf-8

class Klass
  @class_instance_val = :class_instance_val
  @@class_val = :class_val
end

class InheritKlass < Klass
  # InheritKlassに定義されたクラスインスタンス変数へのアクセスとなる
  @class_instance_val #=> nil

  # 親クラスのクラス変数は参照できる
  @@class_val #=> :class_val
end
