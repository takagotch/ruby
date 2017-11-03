#!/ruby/bin/ruby

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
error_msg_color = cf.parm["error_msg_color"]
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

index = cgi.params["index"][0]
if index
  index = index.to_i
else
  index = session["index"].to_i
end

pwd = session["password"]

# Session のクローズ
session["password"] = pwd
session["pos"] = "#{pos}"
session["url_top"] = "#{url_top}"
session["index"] = "#{index}"
session.close

# パスワードのチェック

if pwd == ""
  wl.error_exit("エラーURL一覧", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("エラーURL一覧", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ エラーURL一覧</b></font>
<hr>
</td></tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td align="left">
<a href="master_list.rb?pos=<%=index%>">戻る</a>&nbsp;&nbsp;&nbsp;&nbsp;
</td>
<td align="right">
E
print erb.result

# データベースのオープン
db = Mysql::new(host, userid, password, database)
db.query("SET NAMES utf8")

# 登録サイトのカウント
res1 = db.query("SELECT COUNT(*) FROM url WHERE top_url_id=#{url_top} AND response != '200' AND response != '000'")
stotal = nil
res1.each do |n_str,|
  stotal = n_str.to_i
end

# リストのヘッダー表示
wl.list_header("master_list_skip.rb", pos, limit, stotal)

erb = ERB.new(<<E)
</td>
</tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
</table>

<table width="90%" border="1" cellspacing="2">
<tr bgcolor="<%= table_color %>"><th>ID.</th><th>LVL</th><th>URL</th><th>TITLE</th><th>RES</th></tr>
E
print erb.result

# 登録サイトの検索
res2 = db.query("SELECT url_id, tree_level, url, title, response FROM url WHERE top_url_id=#{url_top} AND response != '200' AND response !='000' ORDER BY url_id LIMIT #{pos - 1},#{limit}")
ln = pos
res2.each do |url_id, tree_level, url, title, response,|
  if title == nil
    title = "&nbsp;"
  end
  print "<tr>"
  print "<td bgcolor=\"#{table_color}\"><center>#{url_id}</center></td>\n"
  print "<td><center>#{tree_level}</center></td>\n"
  print "<td><a href=#{url} target=_blank>#{url}</a></td>\n"
  if response == "000" || response == "200"
    print "<td><b>#{title}</b></td>\n"
    print "<td><center>#{response}</center></td>\n"
  else
    print "<td><b><font color=\"#{error_msg_color}\">#{title}</font></b></td>\n"
    print "<td><center><b><font color=\"#{error_msg_color}\">#{response}</font></b></center></td>\n"
  end
  print "</tr>"
  ln += 1
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
wl.list_fooder("master_list_skip.rb", pos, limit, stotal, max_page, list_name="検索結果ページ")

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
