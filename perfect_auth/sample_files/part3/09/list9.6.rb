# coding: utf-8

class MethodInfo
  def sample_method; end
end

obj = MethodInfo.new # => #<MethodInfo:0x007f9c0c917cd8>
sample_method = obj.method(:sample_method)

# Methodオブジェクトのメソッドが定義されているクラス・モジュール
sample_method.owner # => MethodInfo

# Methodオブジェクトのメソッド名
sample_method.name # => :sample_method

# Methodオブジェクトのレシーバ
sample_method.receiver # => #<MethodInfo:0x007f9c0c917cd8>
sample_method.receiver == obj # => true
