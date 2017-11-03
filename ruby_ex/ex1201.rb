# -*- coding: utf-8 -*-
require 'date'

# 蔵書1冊分の蔵書データのクラスを作る
class BookInfo
  # BookInfoクラスのインスタンスを初期化する
  def initialize( title, author, page, publish_date )
    @title = title
    @author = author
    @page = page
    @publish_date = publish_date
  end

  # 最初に検討する属性に対するアクセサを提供する
  attr_accessor :title, :author, :page, :publish_date

  # BookInfoクラスのインスタンスの文字列表現を返す
  def to_s
    "#{@title}, #{@author}, #{@page}, #{@publish_date}"
  end
end

# 複数冊の蔵書データを登録する
book_infos = Hash.new
book_infos["Yamada2005"] = BookInfo.new(
  "実践アジャイル ソフトウェア開発法とプロジェクト管理",
  "山田 正樹",
  248,
  Date.new( 2005, 1, 25 ) )
book_infos["Ooba2006"] = BookInfo.new(
  "入門LEGO MINDSTORMS NXT レゴブロックで作る動くロボット",
  "大庭 慎一郎",
  164,
  Date.new( 2006, 12, 23 ) )

# 登録した蔵書データを文字列表現で1冊ずつ出力する
# valueがBookinfoクラスのインスタンスになっている事に注意
book_infos.each { |key, value|
  puts "#{key}: #{value.to_s}"
}
