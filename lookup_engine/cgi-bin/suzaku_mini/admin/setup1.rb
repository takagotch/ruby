#!/ruby/bin/ruby

# setup1.rb : データベース設定

require 'cgi'
require 'cgi/session'
require 'nkf'
require 'erb'
require 'mysql'

# Suzaku 共通コンスタント／ライブラリ
require '../lib/constant'
require '../lib/suzaku_lib'
require '../lib/suzaku_weblib.rb'
include Suzaku

# 初期設定
cf = Config.new("../" + Local_conf_file)
host = cf.parm["host"]
userid = cf.parm["userid"]
password = cf.parm["password"]
database = cf.parm["database"]
root_userid = cf.parm["root_userid"]
root_password = cf.parm["root_password"]
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 開始チェック
pwd = session["password"]

# Session のクローズ
session["password"] = pwd
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("システム管理", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("システム管理", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd == 'test'  
  wl.error_exit("システム管理", "実行権限がありません。", "index_system.rb", "ログイン画面へ")
end

# 機能コードのチェック
fc = cgi.params["function"][0]
if fc == "1"
elsif fc == "2"
elsif fc == "3"
elsif fc == "4"
elsif fc == "5"
elsif fc == "6"
elsif fc == "7"
elsif fc == "8"
else
  wl.error_exit("システム管理", "不正な機能コードです。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

msg = ""
# データベースの作成
if fc == "1"
  begin
    # データベースのオープン
    db = Mysql::new(host, root_userid, root_password, 'mysql')
    db.query("SET NAMES utf8")

    # SQL実行
    db.query("CREATE DATABASE #{database}")
    db.query("GRANT ALL PRIVILEGES ON #{database}.* TO #{userid}@#{host} IDENTIFIED BY \"#{password}\"")
    db.query("FLUSH PRIVILEGES")

    # データベースのクローズ
    db.close
    msg = "データベースを作成しました。"

  rescue MysqlError
    msg = "データベースを作成できませんでした。<br>#{$!}"
  end

# データベースの削除
elsif fc == "2"
  begin
    # データベースのオープン
    db = Mysql::new(host, root_userid, root_password, 'mysql')
    db.query("SET NAMES utf8")

    # SQL実行
    db.query("DROP DATABASE #{database}")
    db.query("DELETE FROM user WHERE user=\"#{userid}\" AND host=\"#{host}\"")
    db.query("FLUSH PRIVILEGES")

    # データベースのクローズ
    db.close
    msg = "データベースを削除しました。"

  rescue MysqlError
    msg = "データベースを削除できませんでした。<br>#{$!}"
  end

# テーブルの作成
elsif fc == "3"
  begin
    # データベースのオープン
    db = Mysql::new(host, userid, password, database)
    db.query("SET NAMES utf8")

    # SQL実行

    # keyword
    sql = <<__EOF__
    CREATE TABLE keyword (
            keyword VARCHAR(128) NOT NULL DEFAULT '',
            url_id INT NOT NULL DEFAULT '0',
            score INT NOT NULL DEFAULT '1',
            count INT NOT NULL DEFAULT '1',
            PRIMARY KEY (keyword, url_id),
            INDEX urlid_idx (url_id)
    ) type=MyISAM
__EOF__
    db.query(sql)

    # url
    sql = <<__EOF__
    CREATE TABLE url (
            url_id INT NOT NULL AUTO_INCREMENT,
            url VARCHAR(250) NOT NULL,
            tree_level TINYINT UNSIGNED NOT NULL DEFAULT '1',
            top_url_id INT DEFAULT '-1',
            registed DATETIME NOT NULL,
            last_modified DATETIME NOT NULL,
            last_parsed DATETIME NOT NULL,
            response CHAR(3) DEFAULT '000',
            title TEXT,
            abstract TEXT,
            contents TEXT,
            sequence_id INT,
            PRIMARY KEY (url_id),
            UNIQUE INDEX url_idx (url),
            INDEX top_idx (top_url_id),
            INDEX sequense_id_idx (sequence_id)
    ) type=MyISAM
__EOF__
    db.query(sql)

    # information
    sql = <<__EOF__
    CREATE TABLE information (
      url_id INT NOT NULL,
      category CHAR(2) NOT NULL DEFAULT '99',
      name_kanji VARCHAR(120),
      name_kana VARCHAR(120),
      mail_address VARCHAR(80),
      comment TEXT,
      access TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
      PRIMARY KEY (url_id)
    ) type=MyISAM
__EOF__
    db.query(sql)

    # regist
    sql = <<__EOF__
    CREATE TABLE regist (
      log_id INT NOT NULL AUTO_INCREMENT,
      url VARCHAR(250),
      mail_address VARCHAR(80),
      regist_time DATETIME NOT NULL,
      PRIMARY KEY (log_id)
    ) type=MyISAM
__EOF__
    db.query(sql)

    # searchlog
    sql = <<__EOF__
    CREATE TABLE searchlog (
            log_id INT NOT NULL AUTO_INCREMENT,
            start_time DATETIME NOT NULL,
            process_time float NOT NULL,
            keywords TEXT,
            PRIMARY KEY (log_id)
    ) type=MyISAM
__EOF__
    db.query(sql)

    # データベースのクローズ
    db.close
    msg = "テーブルを作成しました。"
  rescue MysqlError
    msg = "テーブルを作成できませんでした。<br>#{$!}"
  end

# テーブルの削除
elsif fc == "4"
  begin
    # データベースのオープン
    db = Mysql::new(host, userid, password, database)
    db.query("SET NAMES utf8")

    # SQL実行
    db.query("DROP TABLE keyword")
    db.query("DROP TABLE url")
    db.query("DROP TABLE information")
    db.query("DROP TABLE regist")
    db.query("DROP TABLE searchlog")

    # データベースのクローズ
    db.close
    msg = "テーブルを削除しました。"

  rescue MysqlError
    msg = "テーブルを削除できませんでした。<br>#{$!}"
  end

# 登録サイトのバックアップ
elsif fc == "5"
  begin
    # データベースのオープン
    db = Mysql::new(host, userid, password, database)
    db.query("SET NAMES utf8")
    io = open(Url_list_file, "w")

    # 登録サイトの検索(tree_level=1)
    n = 1
    res2 = db.query("SELECT t1.url_id, t1.url, t2.category, t2.name_kanji, t2.name_kana, t2.mail_address, t2.comment, t2.access FROM url t1, information t2 WHERE t1.url_id=t2.url_id AND t1.tree_level=1 ORDER BY t2.category, t2.name_kana")
    res2.each do |urlid, url, category, name_kanji, name_kana, mail_address, comment, access|
      io.puts "#{n},#{urlid},#{url},#{category},#{name_kanji},#{name_kana},#{mail_address},#{comment},#{access}"
      n += 1
    end
    # データベースのクローズ
    db.close
    io.close
    msg = "登録サイトをバックアップしました。"

  rescue
    msg = "登録サイトをバックアップできませんでした。<br>#{$!}"
  end

# 登録サイトの復元
elsif fc == "6"
  begin
    # データベースのオープン
    db = Mysql::new(host, userid, password, database)
    db.query("SET NAMES utf8")
    io = open(Url_list_file, "r")

    while line = io.gets
      data = line.split(/\s*,\s*/, -1)
      n = data[0]
      url_id = data[1]
      url = data[2]
      category = data[3]
      name_kanji = data[4]
      name_kana = data[5]
      mail_address = data[6]
      comment = data[7]
      access = data[8]

      # print "#{n},#{url_id},#{url},#{category},#{name_kanji},#{name_kana},#{mail_address},#{comment},#{access}\n"

      # insert url
      db.query("INSERT INTO url SET url_id=NULL,url='#{Mysql::quote url}',tree_level='1',registed=NOW(),last_modified='0000-00-00 00:00:00',last_parsed='0000-00-00 00:00:00',response='000'")
      # select url
      res2 = db.query("SELECT url_id FROM url WHERE url='#{Mysql::quote url}' AND tree_level='1'")
      res2.each do |url_id|
        # update url
        db.query("UPDATE url SET top_url_id=url_id WHERE url_id=#{url_id}")
        # insert information
        db.query("INSERT INTO information SET url_id=#{url_id},category='#{Mysql::quote category}',name_kanji='#{Mysql::quote name_kanji}',name_kana='#{Mysql::quote name_kana}',mail_address='#{Mysql::quote mail_address}',comment='#{Mysql::quote comment}',access=#{access}")
      end
    end

    # データベースのクローズ
    db.close
    io.close
    msg = "登録サイトを復元しました。"

  rescue
    msg = "登録サイトを復元できませんでした。<br>#{$!}"
  end

# インターネットの巡回を開始
elsif fc == "7"
  msg = "この機能はまだ使用できません。"

# インターネットの巡回を停止
elsif fc == "8"
  begin
    tmp_dir = cf.parm["tmp_dir"]
    ctl = Control.new("../bin/" + tmp_dir)
    ctl.stop
    msg = "インターネットの巡回を停止しました。"

  rescue
    msg = "インターネットの巡回を停止できませんでした。<br>#{$!}"
  end

end

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ 実行結果</b></font>
<hr>
</td></tr>
</table>
<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<b><%= msg %></b>
</td>
</tr>
</table>
<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<hr>
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
