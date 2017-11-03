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
max_page = 10
limit = 50
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

pwd = session["password"]

# Session のクローズ
session["password"] = pwd
session["pos"] = pos
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("検索ログ", "管理者モードではありません。ログインして下さい。", "ndex_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("検索ログ", "パスワードが間違っています。再度ログインして下さい。", "ndex_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ 検索ログ</b></font>
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

# 検索ログのカウント
res1 = db.query("SELECT COUNT(*) FROM searchlog WHERE start_time > SUBDATE(NOW(), INTERVAL 1 MONTH)")
stotal = nil
res1.each do |n_str,|
  stotal = n_str.to_i
end

# リストのヘッダー表示
wl.list_header("searchlog_list.rb", pos, limit, stotal)

erb = ERB.new(<<E)
</td>
</tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
</table>

<table width="90%" border="1" cellspacing="2">
<tr bgcolor="<%= table_color %>"><th>NO.</th><th>START</th><th>PROCESS</th><th>KEYWORDS</th></tr>
E
print erb.result

# 検索ログの検索
res2 = db.query("SELECT start_time, process_time, keywords FROM searchlog WHERE start_time > SUBDATE(NOW(), INTERVAL 1 MONTH) ORDER BY start_time  DESC LIMIT #{pos - 1},#{limit}")
ln = pos
res2.each do |start_time, process_time, keywords|
  print "<tr>"
  print "<td bgcolor=\"#{table_color}\"><center>#{ln}</center></td>\n"
  print "<td><center>#{start_time}</center></td>\n"
  ptime = process_time.to_f
  if ptime < 3.0
    print "<td><center>#{process_time}</center></td>\n"
  else
    print "<td><center><font color=\"#{error_msg_color}\">#{process_time}</font></center></td>\n"
  end
  print "<td>"
  keywords.gsub!(/</, "&lt;")
  keywords.gsub!(/>/, "&gt;")
  if /(.+)(http\:\/\/[^\,]*)(.*)/ =~ keywords
    print $1
    print "<a href=\"#{$2}\" target=\"_blank\">#{$2}</a>"
    print $3
  else
    print keywords
  end
  print "</td>\n"
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
wl.list_fooder("searchlog_list.rb", pos, limit, stotal, max_page, list_name="検索結果ページ")

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
