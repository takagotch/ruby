#!/ruby/bin/ruby

# master_update.rb : サイトの登録・変更・削除処理
#
#   submit1: 登録
#   submit2: 変更
#   submit3: 削除

require 'cgi'
require 'cgi/session'
require 'nkf'
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
if cgi.params["submit1"][0]
  command = "insert"
  url_id = nil
  ln = nil
  msg = "登録結果"
elsif cgi.params["submit2"][0]
  command = "update"
  url_id = cgi.params["url_id"][0].to_i
  ln = cgi.params["ln"][0].to_i
  msg = "変更結果"
elsif cgi.params["submit3"][0]
  command = "delete"
  url_id = cgi.params["url_id"][0].to_i
  ln = cgi.params["ln"][0].to_i
  msg = "削除結果"
else
  command = "unknown"
end

url = cgi.params["url"][0]
category = cgi.params["category"][0]
name_kanji = cgi.params["name_kanji"][0].toutf8
name_kana = cgi.params["name_kana"][0].toutf8
mail_address = cgi.params["mail_address"][0]
comment = cgi.params["comment"][0].toutf8

pwd = session["password"]
pos = session["pos"].to_i

# Session のクローズ
session["password"] = pwd
session["pos"] = "#{pos}"
session.close
# パスワードのチェック
if pwd == ""
  wl.error_exit(msg, "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit(msg, "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd == 'test'  
  wl.error_exit(msg, "更新権限がありません。", "index_system.rb", "ログイン画面へ")
end


header_system(cgi, cf)
menubar_system(cgi, cf)


erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<font size="+0"><b>■ <%=msg%></b></font>
<hr>
</td>
</tr>
</table>
<table width="90%" border="0" cellspacing="0">
E
print erb.result

# データベースのオープン
db = Mysql::new(host, userid, password, database)
db.query("SET NAMES utf8")

# 登録サイトのカウント
res1 = db.query("SELECT COUNT(*) FROM url WHERE tree_level=1")
stotal = nil
res1.each do |n_str,|
  stotal = n_str.to_i
end

# 更新
if command == "update"
  begin
    # update information
    db.query("UPDATE information SET category='#{Mysql::quote category}',name_kanji='#{Mysql::quote name_kanji}',name_kana='#{Mysql::quote name_kana}',mail_address='#{Mysql::quote mail_address}',comment='#{Mysql::quote comment}' WHERE url_id=#{url_id}")
    print "<tr><td><b>登録データを更新しました</b><td><tr>\n"
  rescue MysqlError
    print "<tr><td><b>更新に失敗しました</b><br>#{$!}<td><tr>\n"
  end
# 新規登録
elsif command == "insert"
  # url のチェック
  http = Http.new
  http.set_url(url.untaint)
  ac = http.test
  if ac < 0
    print "<tr><td><b>指定されたURLにアクセスできません</b><br>#{$!}<td><tr>\n"
  else
    begin
      # insert url
      db.query("INSERT INTO url SET url_id=NULL,url='#{Mysql::quote url}',tree_level='1',registed=NOW(),last_modified='0000-00-00 00:00:00',last_parsed='0000-00-00 00:00:00',response='000'")
      # select url
      res2 = db.query("SELECT url_id FROM url WHERE url='#{Mysql::quote url}' AND tree_level='1'")
      res2.each do |url_id|
        # update url
        db.query("UPDATE url SET top_url_id=url_id WHERE url_id=#{url_id}")
        # insert information
        db.query("INSERT INTO information SET url_id=#{url_id},category='#{Mysql::quote category}',name_kanji='#{Mysql::quote name_kanji}',name_kana='#{Mysql::quote name_kana}',mail_address='#{Mysql::quote mail_address}',comment='#{Mysql::quote comment}',access=#{ac}")
      end
      print "<tr><td><b>新規登録しました</b><td><tr>\n"
    rescue MysqlError
      print "<tr><td><b>新規登録に失敗しました</b><br>#{$!}<td><tr>\n"
    end
  end
# 削除
elsif command == "delete"
  begin
    # delete information
    db.query("DELETE FROM information WHERE url_id=#{url_id}")
    # delete url/keyword
    res2 = db.query("SELECT url_id FROM url WHERE top_url_id=#{url_id}")
    res2.each do |id|
      db.query("DELETE FROM url WHERE url_id=#{id}")
      db.query("DELETE FROM keyword WHERE url_id=#{id}")
    end
    print "<tr><td><b>>登録データを削除しました</b><td><tr>\n"
  rescue MysqlError
    print "<tr><td><b>削除に失敗しました</b><br>#{$!}<td><tr>\n"
  end
end
db.close

erb = ERB.new(<<E)
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<hr>
E
print erb.result

if command == "insert"
  # 新規登録へのリンク
  print "<a href=\"master_select.rb\">登録を続ける</a>\n"
elsif command == "update"
  # 一覧表へのリンク
  print "<a href=\"master_list.rb?pos=#{pos}\">一覧表に戻る</a>&nbsp;&nbsp;\n"
  # 変更・削除へのリンク
  print "<a href=\"master_select.rb?ln=#{ln}\">再表示</a>&nbsp;&nbsp;\n"
  if ln - 1 > 0
    print "<a href=\"master_select.rb?ln=#{ln - 1}\">前へ</a>&nbsp;&nbsp;\n"
  end
  if ln + 1 <= stotal
    print "<a href=\"master_select.rb?ln=#{ln + 1}\">次へ</a>\n"
  end  
elsif command == "delete"
  # 一覧表へのリンク
  print "<a href=\"master_list.rb?pos=#{pos}\">一覧表に戻る</a>\n"
end

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
