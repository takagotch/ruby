# coding: utf-8

class EvalTarget
  @class_class_instance = 10
  class << self
    def class_class_instance
      @class_class_instance
    end
  end
end

EvalTarget.class_class_instance #=> 10

# class_eval を使って、クラスクラスインスタンス変数を変更
EvalTarget.class_eval do
  @class_class_instance = 5
end

EvalTarget.class_class_instance #=> 5
