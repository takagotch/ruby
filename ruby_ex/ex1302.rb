# -*- coding: utf-8 -*-
# Studentクラスを作る
class Student
  # Studentクラスのインスタンスを初期化する
  def initialize(name, age)
    @name = name
    @age = age
  end

  # Studentクラスのインスタンスの文字列表現を返す
  def to_s
    "#{@name}, #{@age}"
  end
end

# StudentBookアプリケーションのインスタンスを作る
class StudentBook
  def inisitalize 
    @students = {}
  end

  # ハッシュにStudentクラスのインスタンスを複数作成する
  def setUpStudents
    @students = {                  # studentsをインスタンス変数に変更
      :shin => Student.new( "Shin Kuboaki", 45 ),
      :shinichirou => Student.new( "Shinichirou Ooba", 35 ),
      :shingo => Student.new( "Shingo Katori", 30 ),
    }
  end

  # すべてのインスタンスの名前と年齢を表示する
  # 処理を手続きにする
  def printStudents
    @students.each { |key, value|   # studentsをインスタンス変数に変更
      puts "#{key} #{value.to_s}"
    }
  end

  # StudentBookかデータをリストする
  def listAllStudents
    # Studentクラスのインスタンスの作成
    setUpStudents
    # Studentクラスのインスタンスの表示
    printStudents
  end
end

# StudentBookクラスのインスタンスを作成する
student_book = StudentBook.new

# Studentクラスのインスタンスの表示
student_book.listAllStudents
