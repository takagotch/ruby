# -*- coding: utf-8 -*-
require 'date'
require 'pstore'

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
    "#{@title}, #{@author}, #{@page}, #{@publish_date}"
  end

  # 蔵書データを書式をつけて出力する操作を追加する
  # 項目の区切り文字を引数に指定することができる
  # 引数を省略した場合は改行を区切り文字にする
  def toFormattedString( sep = "\n" )
    "書籍名: #{@title}#{sep}著者名: #{@author}#{sep}ページ数: #{@page}ページ#{sep}発刊日: #{@publish_date}#{sep}"
  end
end

# BookInfoManagerクラスを定義する
class BookInfoManager
  def initialize( pstore_name )
    # PStoreデータベースファイルを指定して初期化
    @db = PStore.new(pstore_name)
  end

  # 蔵書データを登録する
  def addBookInfo
    # 蔵書データ1件分のインスタンスを作成する
    book_info = BookInfo.new( "", "", 0, Date.new )
    # 登録するデータを項目ごとに入力する
    print "\n"
    print "キー: " 
    key = gets.chomp 
    print "書籍名: " 
    book_info.title = gets.chomp 
    print "著者名: "
    book_info.author = gets.chomp 
    print "ページ数: "
    book_info.page = gets.chomp.to_i
    print "発刊年: " 
    year = gets.chomp.to_i
    print "発刊月: " 
    month = gets.chomp.to_i
    print "発刊日: "
    day = gets.chomp.to_i
    book_info.publish_date = Date.new( year, month, day )

    # 作成した蔵書データを1件分をPStoreデータベースに登録する
    @db.transaction do
      # 蔵書データをPStoreに保存する
      @db[key] = book_info
    end
  end

  # 蔵書データの一覧を表示する
  def listAllBookInfos
    puts "\n---------------"
    @db.transaction(true) do    # 読み込みモード
      # roots がキーの配列を返し、each でそれを1件ずつ処理
      @db.roots.each { |key|
        # 得られたキーを使ってPStoreから蔵書データ（BookInfo）を取得
        # それを書式をつけて出力する
        puts "キー: #{key}"
        print @db[key].toFormattedString
        puts "\n---------------"
      }
    end
  end

  # 蔵書データを削除する
  def delBookInfo
    # キーを指定してもらう
    print "\n"
    print "キーを指定してください："
    key = gets.chomp 
    
    # 削除対象データを確認してから削除する
    @db.transaction do
      if @db.root?(key)
        print @db[key].toFormattedString
        print "\n削除しますか？(Y/yなら削除を実行します)："
        # 読み込んだ値を大文字に揃える
        yesno = gets.chomp.upcase
        if /^Y$/ =~ yesno
          # Yが1文字のときだけ、PStoreデータベースから削除する
          @db.delete(key)
          puts "\nデータベースから削除しました"
        end
      end
    end
  end

  # 処理の選択と選択後の処理を繰り返す
  def run
    while true
      # 機能選択画面を表示する
      print "
1. 蔵書データの登録
2. 蔵書データの表示
3. 蔵書データの削除
9. 終了
番号を選んでください(1,2,3,9)："
      
      # 文字の入力を待つ
      num = gets.chomp
      case 
      when '1' == num
        # 蔵書データの登録
        addBookInfo
      when '2' == num
        # 蔵書データの表示
        listAllBookInfos
      when '3' == num
        # 蔵書データの削除
        delBookInfo
      when '9' == num
        # アプリケーションの終了
        break;
      else
        # 処理選択待ち画面に戻る
      end
    end
  end

end

# ここからがアプリケーションを動かす本体

# アプリケーションのインスタンスを作る
# 蔵書データのPStoreデータベースを指定している
book_info_manager = BookInfoManager.new("book_info.db")

# BookInfoManagerの処理の選択と選択後の処理を繰り返す
book_info_manager.run
