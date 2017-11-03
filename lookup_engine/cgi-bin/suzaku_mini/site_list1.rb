#!/ruby/bin/ruby

require 'cgi'
require 'nkf'
require 'erb'
require 'mysql'

# Suzaku 共通コンスタント／ライブラリ
require 'lib/constant.rb'
require 'lib/suzaku_lib.rb'
require 'lib/suzaku_weblib.rb'
include Suzaku

# 初期設定
cf = Config.new(Local_conf_file)
table_color = cf.parm["table_color"]

host = cf.parm["host"]
userid = cf.parm["userid"]
password = cf.parm["password"]
database = cf.parm["database"]
category = Hash.new
cf.parm.keys.sort.each do |x|
  if /\A\d\d\Z/ =~ x
    category[x] = cf.parm[x]
  end
end

max_page = 10
limit = 50
wl = Weblib.new

# CGI のオープン
cgi = CGI.new

# 開始チェック
pos = cgi.params["pos"][0]
if pos
  pos = cgi.params["pos"][0].to_i
else
  pos = 1
end

type = cgi.params["type"][0]
if type
else
  type = '01'
end


header(cgi, cf)
menubar(cgi, cf)

erb = ERB.new(<<E)
<center>

<table width="600" border="0" cellspacing="0">
  <tr>
    <td><br>
    <font size="+1"><b>■ 検索対象サイト</b></font>
    <hr>
    </td>
  </tr>
</table>

<table width="600" border="0" cellspacing="0">

<tr>
<td align="left">
<b>[ <%= category[type] %> ]</b>
</td>
<td align="right">
E
print erb.result

# データベースのオープン
db = Mysql::new(host, userid, password, database)
db.query("SET NAMES utf8")

# 登録サイトのカウント
res1 = db.query("SELECT COUNT(*) FROM url t1, information t2 WHERE t1.url_id=t2.url_id AND t1.tree_level=1 AND t2.category='#{type}'")
stotal = nil
res1.each do |n_str,|
  stotal = n_str.to_i
end

# リストのヘッダー表示
wl.list_header("site_list1.rb", pos, limit, stotal,"&type=#{type}")

erb = ERB.new(<<E)
</td>
</tr>
</table>

<table width="600" border="0" cellspacing="0">
<tr><td><hr></td></tr>
</table>

<table width="600" border="1" cellspacing="2">
<!-- <th>NO.</th><th>NAME</th><th>NAME(KANA)</th><th>URL</th><th>PAGE</th> -->
<th bgcolor="<%= table_color %>">NO.</th><th bgcolor="<%= table_color %>">NAME</th><th bgcolor="<%= table_color %>">URL</th><th bgcolor="<%= table_color %>">PAGE</th>
E
print erb.result

# 登録サイトの検索
res2 = db.query("SELECT t1.url_id, t1.url, t1.title, t1.top_url_id, t1.response, t2.name_kanji, t2.name_kana  FROM url t1, information t2 WHERE t1.url_id=t2.url_id AND t1.tree_level=1 AND t2.category='#{type}' ORDER BY t2.name_kana LIMIT #{pos - 1},#{limit}")

ln = pos
res2.each do |urlid, url, title, top_url_id, response, name_kanji, name_kana|
  if title == nil
    title = "&nbsp;"
  end  
  if name_kanji == nil
    name_kanji = "&nbsp;"
  end
  print "<tr>"
  print "<td bgcolor=\"#{table_color}\"><center>#{ln}</center></td>\n"
  print "<td>#{name_kanji}</td>\n"
# print "<td>#{name_kana}</td>\n"
  print "<td><a href=#{url} target=_blank>#{url}</a></td>\n"
# print "<td><b>#{title}</b></td>\n"

  # 巡回状況の検索
  c_ok = nil
  res3 = db.query("SELECT count(*) FROM url WHERE top_url_id=#{top_url_id} AND response='200'")
  res3.each do |n,|
    c_ok = n.to_i
  end
  print "<td align=\"right\" >#{c_ok}</a></td>\n"
  print "</tr>"
  ln += 1
end
db.close

erb = ERB.new(<<E)
</table>
<table width="600" border="0" cellspacing="0">
<tr><td><hr></td></tr>
<tr>
<td align="center">
E
print erb.result

# リストのフッダー表示
wl.list_fooder("site_list1.rb", pos, limit, stotal, max_page, list_name="検索結果ページ","&type=#{type}")

erb = ERB.new(<<E)
</td>
</tr>
<tr> 
  <td>
    <hr>
    <div align="center"><a href="index.rb">HOME</a> </div>
  </td>
</tr>
</table>
</center>
E
print erb.result

footer(cgi, cf)
