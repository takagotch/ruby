# coding: utf-8

class LoggingInstanceVariable
  attr_reader :first_val, :before_first_val

  def first_val=(val)
    @before_first_val = @first_val
    @first_val = val
  end
end

obj = LoggingInstanceVariable.new

obj.first_val = 1

obj.first_val #=> 1
# 初期化してないインスタンス変数の最初の値はnil obj.before_first_val #=> nil
obj.first_val = 2

obj.first_val #=> 2
obj.before_first_val #=> 1
