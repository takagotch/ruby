#!/ruby/bin/ruby

# master_select_url.rb : サイトのURL変更用フォームの表示

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
max_page = 20
limit = 100
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 開始チェック
ln = cgi.params["ln"][0].to_i
url_id = nil
pwd = session["password"]
pos = session["pos"].to_i

# Session のクローズ
session["password"] = pwd
session["pos"] = "#{pos}"
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("URLの変更", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("URLの変更", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<form action="master_update_url.rb" method=post>

<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<font size="+0"><b>■ URLの変更</b></font>
<hr>
</td>
</tr>
</table>

<table width="90%" border="0" cellspacing="2">
E
print erb.result

# 初期設定
url = ""
title = ""
category = ""
name_kanji = ""
name_kana = ""
mail_address = ""
comment = ""
access = ""
  
# 登録サイトの検索
 
# データベースのオープン
db = Mysql::new(host, userid, password, database)
db.query("SET NAMES utf8")
    
# 指定された登録サイトの検索
res2 = db.query("SELECT t1.url_id, t1.url, t1.title, t2.category, t2.name_kanji, t2.name_kana, t2.mail_address, t2.comment, t2.access FROM url t1, information t2 WHERE t1.url_id=t2.url_id AND t1.tree_level=1 ORDER BY t2.category, t2.name_kana LIMIT #{ln - 1},1")

res2.each do |url_id, url, title, category, name_kanji, name_kana, mail_address, comment, access|
end
# データベースのクローズ
db.close  
if title
else
  title = "unknown"
end
  
# 登録データの表示
# url
print "<tr><td>URL(変更前):</td>"
print "<td><a href=\"#{url}\" target=_blank>#{url}</a></td></tr>\n"
print "<tr><td>URL(変更後):</td>"
print "<td><input type=\"text\" name=\"new_url\" size=50 value=\"http://\"</td></tr>\n";
# 登録
print "<tr><td>\n"
print "<input type=\"submit\" name=\"submit\" value=\"変更\">\n"
print "</td></tr>\n"

erb = ERB.new(<<E)
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<hr>
E
print erb.result

print "<a href=\"master_select.rb?ln=#{ln}\">戻る</a>\n"

erb = ERB.new(<<E)
</td>
</tr>
</table>
E
print erb.result

print "<input type=\"hidden\" name=\"ln\" value=#{ln}>\n"

erb = ERB.new(<<E)
</form>
</center>
E
print erb.result

footer_system(cgi, cf)
