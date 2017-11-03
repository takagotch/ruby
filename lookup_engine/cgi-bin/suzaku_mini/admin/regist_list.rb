#!/ruby/bin/ruby

# regist_list.rb : 推薦サイトの一覧表示

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
table_color = cf.parm["table_color"]
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
pos = cgi.params["pos"][0]
if pos
  pos = pos.to_i
else
  pos = 1
end

url_top = cgi.params["url_top"][0]
if url_top
  url_top = url_top.to_i
else
  url_top = session["url_top"].to_i
end

pwd = session["password"]

# Session のクローズ
session["password"] = pwd
session["pos"] = "#{pos}"
session["url_top"] = "#{url_top}"
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("サイトの推薦一覧", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("サイトの推薦一覧", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ サイトの推薦一覧</b></font>
<hr>
</td></tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td align="left">
</td>
<td align="right">
E
print erb.result

# データベースのオープン
db = Mysql::new(host, userid, password, database)
db.query("SET NAMES utf8")

# 推薦サイトのカウント
res1 = db.query("SELECT COUNT(*) FROM regist")
stotal = nil
res1.each do |n_str,|
  stotal = n_str.to_i
end

# リストのヘッダー表示
wl.list_header("regist_list.rb", pos, limit, stotal)

erb = ERB.new(<<E)
</td>
</tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
</table>

<table width="90%" border="1" cellspacing="2">
<tr bgcolor="<%= table_color %>"><th>ID.</th><th>URL</th><th>MAIL</th><th>DATE</th><th>REGISTED</th></tr>
E
print erb.result

# 推薦サイトの検索
res2 = db.query("SELECT log_id, url, mail_address, regist_time FROM regist ORDER BY regist_time DESC LIMIT #{pos - 1},#{limit}")
n = pos
res2.each do |logid, url, mail, regist_time,|
  print "<tr>"
  print "<td bgcolor=\"#{table_color}\"><center>#{logid}</center></td>\n"
  print "<td><a href=\"#{url}\" target=_blank>#{url}</a></td>\n"
  print "<td><a href=\"mailto:#{mail}\" target=_blank>#{mail}</a></td>\n"
  print "<td><center>#{regist_time}</center></td>\n"

  # 推薦サイトは登録済?
  if /(^http:\/\/\S+\/)(\S*)/ =~ url
    res3 = db.query("SELECT count(*) FROM url WHERE url LIKE '#{Mysql::quote $1}%'")
    ct = 0
    res3.each do |n,|
      ct = n.to_i
    end
    if ct > 0
      print "<td><center><b><font color=\"#{table_color}\">#{ct}</font></b></center></td>\n"
    else
      print "<td><center>#{ct}</center></center></td>\n"
    end
    print "</tr>"
  else
    print "<td><center><b><font color=\"#{table_color}\">error</font></b></center></td>\n"
  end
end
db.close

erb = ERB.new(<<E)
</table>
<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
<tr>
<td align="center">
E
print erb.result

# リストのフッダー表示
wl.list_fooder("regist_list.rb", pos, limit, stotal, max_page, list_name="検索結果ページ")

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
