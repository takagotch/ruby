# -*- coding: utf-8 -*-
require 'pstore'

# PStoreデータベースをオープンする
db = PStore.new('fruitdb')

# PStoreが読み込みモードのときに
# 書き込もうとするとエラーになる
db.transaction(true) do 
  db["drink"] = "grape juce"
 end 

