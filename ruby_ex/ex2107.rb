# -*- coding: utf-8 -*-
require 'rubygems'  # RubyGemsでインストールしたときには記述
require 'dbi'       # DBIを使う

# dbhを作成し、データベース'fruits01.db'に接続する
# もし既に存在するときは、そのデータベースファイルを開く
dbh = DBI.connect( 'DBI:SQLite3:fruits01.db' )

# もしすでにこのデータベースにテーブル'products'があれば削除する
dbh.do("drop table if exists products")
puts "table 'products' has dropped."

# 新しく'products'テーブルを作成する
dbh.do("create table products (
    id              int           not null,
    title           varchar(100)  not null,
    description     text          not null,
    image_url       varchar(200)  not null,
    price           int           not null,
    date_available  datetime      not null,
    primary         key(id));")
puts "table 'products' has created."

# データベースとの接続を終了する
dbh.disconnect
