# -*- coding: utf-8 -*-
require 'date'

# 表示したい蔵書データを作成する
publish_date = Date.new( 2005, 1, 25 )
purchase_date = Date.new( 2005, 3, 15)

# 蔵書データを表示する
puts "出版年: " + publish_date.year.to_s
puts "出版月: " + publish_date.mon.to_s
puts "購入日: " + purchase_date.to_s
