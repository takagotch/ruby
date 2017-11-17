# coding: utf-8

class InstanceCountClass
  @instance_count = 0 # クラスインスタンス変数の初期化

  def self.instance_count_up
    @instance_count += 1 if @instance_count
  end

  def self.instance_count
    @instance_count
  end

  def initialize
    self.class.instance_count_up
  end
end

5.times do
  InstanceCountClass.new
end

InstanceCountClass.instance_count #=> 5
