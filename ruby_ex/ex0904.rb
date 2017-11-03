# -*- coding: utf-8 -*-
# Studentクラスを作る
class Student
  # Studentクラスのインスタンスを初期化する
  def initialize( name, age )
    @name = name
    @age = age
  end

  # name属性、age属性のアクセサ
  attr_accessor :name, :age

  # Studentクラスのインスタンスの文字列表現を返す
  def to_s
    "#@name, #@age"
  end
end

# Studentクラスのインスタンスを作成する
shin = Student.new('久保秋　真', 45)

# ゲッターを使ってインスタンスの名前と年齢を表示する
puts "氏名：#{shin.name}、年齢：#{shin.age}歳"

# セッターを使ってshinの名前と年齢を変更する
shin.name = 'Singh, Tiger Jeet'
shin.age = 445

# ゲッターを使ってshinの名前と年齢を表示する
puts shin.name
puts shin.age

puts "氏名：#{shin.name}、年齢：#{shin.age}歳"
