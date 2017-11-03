#!/ruby/bin/ruby

# master_update.rb : サイトのURL変更処理

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
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 開始チェック
ln = cgi.params["ln"][0].to_i
new_url = cgi.params["new_url"][0]

pwd = session["password"]
pos = session["pos"].to_i

# Session のクローズ
session["password"] = pwd
session["pos"] = "#{pos}"
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("URLの変更結果", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("URL変更結果", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd == 'test'  
  wl.error_exit("URL変更結果", "更新権限がありません。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ URL変更結果</b></font>
<hr>
</td></tr>
</table>
<table width="90%" border="0" cellspacing="0">
E
print erb.result

# 初期設定
url_id = nil
url = ""
title = ""
category = ""
name_kanji = ""
name_kana = ""
mail_address = ""
comment = ""

# url のチェック
http = Http.new
http.set_url(new_url.untaint)
ac = http.test
if ac < 0
  print "<tr><td><b>指定されたURLにアクセスできません</b><br>#{$!}<td><tr>\n"
else
  # データベースのオープン
  db = Mysql::new(host, userid, password, database)
  db.query("SET NAMES utf8")

  # 指定された登録サイトの検索
  res2 = db.query("SELECT t1.url_id, t1.url, t1.title, t2.category, t2.name_kanji, t2.name_kana, t2.mail_address, t2.comment FROM url t1, information t2 WHERE t1.url_id=t2.url_id AND t1.tree_level=1 ORDER BY t2.category, t2.name_kana LIMIT #{ln - 1},1")

  res2.each do |url_id, url, title, category, name_kanji, name_kana, mail_address, comment|
  end

  # データの削除＆登録
  begin
    # delete information
    db.query("DELETE FROM information WHERE url_id=#{url_id}")
    # delete url/keyword
    res2 = db.query("SELECT url_id FROM url WHERE top_url_id=#{url_id}")
    res2.each do |id|
      db.query("DELETE FROM url WHERE url_id=#{id}")
      db.query("DELETE FROM keyword WHERE url_id=#{id}")
    end
    
    # insert url
    db.query("INSERT INTO url SET url_id=NULL,url='#{Mysql::quote new_url}',tree_level='1',registed=NOW(),last_modified='0000-00-00 00:00:00',last_parsed='0000-00-00 00:00:00',response='000'")
    # select url
    res2 = db.query("SELECT url_id FROM url WHERE url='#{Mysql::quote new_url}' AND tree_level='1'")
    res2.each do |url_id|
      # update url
      db.query("UPDATE url SET top_url_id=url_id WHERE url_id=#{url_id}")
      # insert information
      db.query("INSERT INTO information SET url_id=#{url_id},category='#{Mysql::quote category}',name_kanji='#{Mysql::quote name_kanji}',name_kana='#{Mysql::quote name_kana}',mail_address='#{Mysql::quote mail_address}',comment='#{Mysql::quote comment}',access=#{ac}")
    end
    print "<tr><td><b>データの削除＆登録を行いました</b><td><tr>\n"
  rescue MysqlError
    print "<tr><td><b>データの削除＆登録に失敗しました</b><br>#{$!.error}:{$!.errno}<td><tr>\n"
  end
  db.close
end

erb = ERB.new(<<E)
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<hr>
E
print erb.result

# サイト変更・削除へのリンク
print "<a href=\"master_select.rb?ln=#{ln}\">戻る</a>\n"

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
