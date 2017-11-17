# coding: utf-8

class InheritedTiming
  class << self
    private

    def inherited(subclass)
      p subclass.ancestors
      p subclass.instance_methods.include? :super_method
      p subclass.instance_methods.include? :subclass_method
    end
  end

  def super_method
  end
end

puts "クラス定義式の前"

class InheritedTimingSubClass < InheritedTiming
  puts "クラス定義式の後"

  def subclass_method
  end
end

p InheritedTimingSubClass.instance_methods.include? :super_method
p InheritedTimingSubClass.instance_methods.include? :subclass_method
