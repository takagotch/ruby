# -*- coding: utf-8 -*-
# 新しいハッシュを作る
friends = { 
  :shin => "Shin Kuboaki", 
  :shinichirou => "Shinichirou Ooba", 
  :shingo => "Shingo Katori" 
}

# ハッシュのキーをひとつずつ処理する
# 繰り返し都度、キーをブロック内のローカル変数keyに渡す
friends.each_key { |key| 
  # ローカル変数（キー）の値を表示する
  puts "#{key} "
}


