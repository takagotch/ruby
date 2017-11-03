# -*- coding: utf-8 -*-
require 'date'

# 蔵書1冊分の蔵書データのクラスを作る
class BookInfo
  # Bookinfoクラスのインスタンスを初期化する
  def initialize( title, author, page, publish_date )
    @title = title
    @author = author
    @page = page
    @publish_date = publish_date
  end

  # 最初に検討する属性に対するアクセサを提供する
  attr_accessor :title, :author, :page, :publish_date

  # Bookinfoクラスのインスタンスの文字列表現を返す
  def to_s
    "#@title, #@author, #@page, #@publish_date"
  end
end

# BookInfoクラスのインスタンスを作成し、book_infoという名前をつける
book_info = BookInfo.new(
  "実践アジャイル ソフトウェア開発法とプロジェクト管理", 
  "山田 正樹",
  248,
  Date.new( 2005, 1, 25 ) )

# book_infoのデータの文字列表現を得る
puts book_info.to_s

# book_infoのアクセサを使ってみる
puts "書籍名: " + book_info.title
puts "著者名: " + book_info.author
puts "ページ数: " + book_info.page.to_s + "ページ"
puts "発刊日: " + book_info.publish_date.to_s
