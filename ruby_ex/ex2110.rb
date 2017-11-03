# -*- coding: utf-8 -*-
require 'rubygems'  # RubyGemsでインストールしたときには記述
require 'dbi'       # DBIを使う

# データベース'fruits01.db'に接続する
dbh = DBI.connect( 'DBI:SQLite3:fruits01.db' )

# テーブルに登録されたデータを削除する
# delete文の実行
# sthにexecuteメソッドが返すステートメントハンドルを保持
sth = dbh.execute("delete from products")
puts "all records are deleted."
 
# ステートメントハンドルを解放する
sth.finish

# サーバから切断
dbh.disconnect
