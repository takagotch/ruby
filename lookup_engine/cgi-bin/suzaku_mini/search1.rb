#!/ruby/bin/ruby

require 'cgi'
require 'cgi/session'
require 'nkf'
require 'erb'

# Suzaku 共通コンスタント／ライブラリ
require 'lib/constant'
require 'lib/suzaku_lib'
require 'lib/suzaku_weblib'
include Suzaku

cf = Config.new(Local_conf_file)
result_color = cf.parm["result_color"]
score_color = cf.parm["score_color"]
info_color = cf.parm["info_color"]

# 検索処理プログラム
require 'search.rb'

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 初期設定
max_page = 10
first_f = false
wl = Weblib.new

# 検索開始のチェック

if cgi.params["start"][0] && cgi.params["start"][0] == "1"
  first_f = true
  # キーワード(AND)
  if cgi.params["key_and"][0]
    session["key_and"] = cgi.params["key_and"][0]
  else
    session["key_and"] = ""
  end
  # キーワード(OR)
  if cgi.params["key_or"][0]
    session["key_or"] = cgi.params["key_or"][0]
  else
    session["key_or"] = ""
  end
  # キーワード(NOT)
  if cgi.params["key_not"][0]
    session["key_not"] = cgi.params["key_not"][0]
  else
    session["key_not"] = ""
  end
  # URL
  if cgi.params["url"][0]
    session["url"] = cgi.params["url"][0]
  else
    session["url"] = ""
  end
  # 表示件数
  if cgi.params["limit"][0]
    session["limit"] = cgi.params["limit"][0]
  else
    session["limit"] = "10"
  end  
  # 表示順
  if cgi.params["order"][0]
    session["order"] = cgi.params["order"][0]
  else
    session["order"] = "1"
  end
  # 表示形式
  if cgi.params["style"][0]
    session["style"] = cgi.params["style"][0]
  else
    session["style"] = "1"
  end
  # 表示位置
  if cgi.params["pos"][0]
    session["pos"] = cgi.params["pos"][0]
  else
    session["pos"] = "1"
  end
# 2回目以降の場合
else
  # 表示位置
  if cgi.params["pos"][0]
    session["pos"] = cgi.params["pos"][0]
  else
    session["pos"] = "1"
  end
end

key_and = session["key_and"]
key_or  = session["key_or"]
key_not = session["key_not"]
url     = session["url"]
limit   = session["limit"].to_i
order   = session["order"].to_i
style   = session["style"].to_i
pos     = session["pos"].to_i

# urlの指定が 'http://' のみの場合は無効にする
if url == 'http://'
  url = ""
end

# 処理開始
time1 = Time.now

# 検索処理
se = SearchEngine.new

if pos < 1
  pos = 1
end

se.db_open
err_msg = nil
sstr = "( )"
begin
  res, stotal, sstr = se.search(key_and, key_or, key_not, url, order, pos, limit)
rescue => ex
  raise
  wl.error_exit("検索失敗", "検索処理が異常終了しました。<br>#{ex.message}", "index.rb", "検索画面へ")
  stotal = 0
end

# 終了時間をセット
time2 = Time.now
tt = time2.to_f - time1.to_f

# ログ出力
if first_f
  keywords = ""
  keywords << key_and << "," << key_or << "," << key_not << "," << url << "," << "#{limit}" << "," << "#{order}" << "," << "#{style}" << "," << "#{pos}"
  se.log(time1, time2 - time1, keywords)
end

# Session のクローズ
session.close


header(cgi, cf)
menubar(cgi, cf)

erb = ERB.new(<<E)
<!-- キーワード入力フォーム -->
<center>
<form action="search1.rb" method=post>
<input type="hidden" name="start" value="1">
<table border="0" cellspacing="2">
<tr>
  <td>キーワード：</td>
  <td> 
E
print erb.result

print "<input type=\"text\" name=\"key_and\" size=\"30\" value=\"#{key_and}\">\n"

erb = ERB.new(<<E)
    &nbsp;&nbsp;<input type="submit" name="submit" value="検索開始">
  </td>
</tr>
</table>
</form>
</center>

<center>
<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
  <td align="left">
    <font color="<%= result_color %>"><b>&nbsp;<%= sstr %>&nbsp;</b></font>の検索結果&nbsp;<font color="<%= result_color %>"><b><%= stotal %></b></font>&nbsp;件&nbsp;&nbsp;
E
print erb.result

printf("<font color=\"#{info_color}\">[検索時間 %6.2f sec]</font>\n", tt)

erb = ERB.new(<<E)
    </td>
  <td align="right">
E
print erb.result

# リストのヘッダー表示
wl.list_header("search1.rb", pos, limit, stotal)

erb = ERB.new(<<E)
  </td>
</tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
<tr>
  <td>
  <br>
E
print erb.result

# リスト本体の表示
if err_msg
  print "<center>"; print err_msg; print "</center><br>\n"
else
  ln = pos
  res.each do |urlid, url, score, last_modified, title, abstract,|
    if title == nil
      title = "無題"
    end
    print "#{ln}.&nbsp;&nbsp;<b><a href=#{url} target=\"_blank\">#{title}</a></b>"
    print "<font color=\"#{score_color}\">&nbsp;&nbsp;score: "; printf("%d", score.to_i); print "</font><br>\n"
    if style == 1
      print "#{abstract}<br>\n"
    end
    print "<font size=\"-1\" color=\"#{info_color}\">[#{urlid}] #{url}&nbsp;&nbsp;Last Modified:#{last_modified}</font><br><br>\n"
    ln += 1
  end
end
se.db_close

erb = ERB.new(<<E)
  </td>
</tr>
<tr><td><hr></td></tr>
<tr>
  <td align="center">
E
print erb.result

# リストのフッダー表示
wl.list_fooder("search1.rb", pos, limit, stotal, max_page, list_name="検索結果ページ")

erb = ERB.new(<<E)
  </td>
</tr>
<tr><td><hr></td></tr>
</table>
</center>

<!-- キーワード入力フォーム -->
<center>
<form action="search1.rb" method=post>
<input type="hidden" name="start" value="1">
<table border="0" cellspacing="2">
<tr>
  <td>キーワード</td>
  <td> 
E
print erb.result

print "<input type=\"text\" name=\"key_and\" size=\"30\" value=\"#{key_and}\">\n"

erb = ERB.new(<<E)
    &nbsp;&nbsp;<input type="submit" name="submit" value="検索開始">
  </td>
</tr>
</table>
</form>
<table width="90%" border="0" cellspacing="0">
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
GC.start
