# coding: utf-8

class Dog
  def bark
    puts 'wan!!'
  end
end

dog = Dog.new
bark_wan = dog.method(:bark)

# Methodオブジェクトを取得したメソッドを書き換える
class Dog
  def bark
    puts 'bowwow!!'
  end
end

# dogオブジェクトのbarkメソッドは書き換えた結果が反映されている
dog.bark # => bowwow!!

# Methodオブジェクトのほうには書き換えた影響はない
bark_wan.call # => wan!!

# Methodオブジェクトを取得したメソッドを特異メソッドとして書き換える
def dog.bark
  puts 'kyankyan!!'
end

dog.bark # => kyankyan!!

# Methodオブジェクトのほうには書き換えた影響はない
bark_wan.call # => wan!!
