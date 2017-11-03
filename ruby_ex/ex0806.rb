# -*- coding: utf-8 -*-
require 'date'

# 表示したい蔵書データを作成する（同じ蔵書は各配列の添字が同じ）
titles = [ 
    "実践アジャイル ソフトウェア開発法とプロジェクト管理", 
    "入門LEGO MINDSTORMS NXT レゴブロックで作る動くロボット",
    ]
authors = [ "山田 正樹", "大庭 慎一郎", ]
yomies = ["やまだまさき", "おおばしんいちろう", ]
publishers = [ 
    "ソフトリサーチセンター", 
    "ソフトバンククリエイティブ", 
    ]
pages = [ 248, 164, ]
prices = [ 2500, 2400, ]
purchase_prices = [ 2650, 2520, ]

isbn_10s   = [ "4883732088", "4797338253", ]
isbn_13s   = [ "978-4883732081", "978-4797338256", ]
sizes      = [ "21 x 14.8 x 2", "23 x 18.2 x 1.6", ]
publish_dates = [ Date.new( 2005, 1, 25 ), Date.new( 2006, 12, 23 ), ]
purchase_dates = [ Date.new( 2005, 2, 2 ), Date.new( 2007, 1, 10 ), ]

# 蔵書データを表示する
titles.size.times { |i|   # titles の要素数分添字をiとして処理を繰り返す
  puts "---------------"
  puts "書籍名: " + titles[i]
  puts "著者名: " + authors[i]
  puts "よみがな: " + yomies[i]
  puts "出版社: " + publishers[i]
  puts "ページ数: " + pages[i].to_s + "ページ"
  puts "販売価格: " + prices[i].to_s + "円"
  puts "購入費用: " + purchase_prices[i].to_s + "円"
  puts "ISBN_10: " + isbn_10s[i]
  puts "ISBN_13: " + isbn_13s[i]
  puts "寸法: " + sizes[i]
  puts "発刊日: " + publish_dates[i].to_s
  puts "購入日: " + purchase_dates[i].to_s
}
