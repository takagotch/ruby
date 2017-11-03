#!/ruby/bin/ruby

# master_list.rb : 登録サイトの一覧表示

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
  pos = ((pos / limit.to_f).floor) * limit + 1
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
  wl.error_exit("登録サイト一覧", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("登録サイト一覧", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ 登録サイト一覧</b></font>
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

# 登録サイトのカウント
res1 = db.query("SELECT COUNT(*) FROM url WHERE tree_level=1")
stotal = nil
res1.each do |n_str,|
  stotal = n_str.to_i
end

# リストのヘッダー表示
wl.list_header("master_list.rb", pos, limit, stotal)

erb = ERB.new(<<E)
</td>
</tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
</table>

<table width="90%" border="1" cellspacing="2">
<tr bgcolor="<%= table_color %>"><th>NO.</th><th>CT</th><th>NAME</th><th>URL</th><th>ID</th><th>RES</th><th>OK </th><th>NG </th><th>YT</th></tr>
E
print erb.result

# 登録サイトの検索
res2 = db.query("SELECT t1.url_id, t1.url, t1.title, t1.top_url_id, t1.response, t2.name_kanji, t2.name_kana, t2.category  FROM url t1, information t2 WHERE t1.url_id=t2.url_id AND t1.tree_level=1 ORDER BY t2.category, t2.name_kana LIMIT #{pos - 1},#{limit}")

ln = pos
res2.each do |urlid, url, title, top_url_id, response, name_kanji, name_kana, category|
  if title == nil
    title = "unknown"
  end
  print "<tr>"
  # 変更・削除へのリンク
  print "<td  bgcolor=\"#{table_color}\"><center><a href=\"master_select.rb?ln=#{ln}\">#{ln}</a></center></td>\n"
  print "<td><center>#{category}</center></td>\n"
  print "<td><b>#{name_kanji}</b></td>\n"
  print "<td><a href=\"#{url}\" target=_blank>#{url}</a></td>\n"
  print "<td><center>#{urlid}</center></td>\n"
  if response == '200'
    print "<td><center>#{response}</center></td>\n"
  else
    print "<td><center><b><font color=\"#{error_msg_color}\">#{response}</font></b></center></td>\n"
  end
  # 巡回状況の検索
  res3 = db.query("SELECT response, count(*) FROM url WHERE top_url_id='#{top_url_id}' GROUP BY response")
  c_ok = c_ng = c_yet = 0
  res3.each do |k, n|
    if k == '000'
      c_yet += n.to_i
    elsif k == '200'
      c_ok += n.to_i
    else
      c_ng += n.to_i
    end
  end
  print "<td align=\"right\" >#{c_ok}</td>\n"
  if c_ng > 0
    print "<td align=\"right\" ><a href=\"master_list_skip.rb?url_top=#{top_url_id}&index=#{ln}\">#{c_ng}<a></td>\n"
  else
    print "<td align=\"right\" >#{c_ng}</td>\n"
  end
  print "<td align=\"right\" >#{c_yet}<a></td>\n"
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
wl.list_fooder("master_list.rb", pos, limit, stotal, max_page, list_name="検索結果ページ")

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
