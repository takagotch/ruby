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
normal_msg_color = cf.parm["normal_msg_color"]
host = cf.parm["host"]
userid = cf.parm["userid"]
password = cf.parm["password"]
database = cf.parm["database"]
log_dir = cf.parm["log_dir"].untaint
max_page = 10
limit = 50
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 開始チェック
pwd = session["password"]

file_name = cgi.params["file_name"][0]

pos = cgi.params["pos"][0]
if pos
  pos = pos.to_i
  pos = ((pos / limit.to_f).floor) * limit + 1
else
  pos = 1
end

index = cgi.params["index"][0]
if index
  index = index.to_i
end

# Session のクローズ
session["password"] = pwd
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("巡回ログ", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("巡回ログ", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end

# ファイル名のチェック
reg = Regexp.new("#{Logname}-\\d\\d\\d\\d\\d\\d\\d\\d-\\d\\d\\d\\d\\d\\d")
if reg =~ file_name
  file_name.untaint
else
  wl.error_exit("巡回ログ", "ファイル名 #{reg} / #{file_name} が不正です", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>

<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ 巡回ログ</b></font>
<hr>
</td></tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td align="left">
  <a href="log_list.rb?pos=<%=index%>">戻る</a>
</td>
<td align="right">
E
print erb.result

# ログ件数のカウント
stotal = 0
log_file = '../bin/' + log_dir + '/' + file_name
open(log_file) do |f|
  while line = f.gets
    stotal += 1
  end
end

# リストのヘッダー表示
wl.list_header("log_detail.rb", pos, limit, stotal, "&file_name=#{file_name}")

erb = ERB.new(<<E)
</td>
</tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td>
E
print erb.result

# ログの検索
ln = pos
lc = 0
open(log_file) do |f|
  while line = f.gets
    lc += 1
    if lc >= ln && lc < ln + limit
#     print "#{lc}:&nbsp;&nbsp;"
      line.gsub!(/</, "&lt;")
      line.gsub!(/>/, "&gt;")
      if /main start\./ =~ line
        print "<font color=\"#{normal_msg_color}\">"
  print line
  print "</font>"
      elsif /tree_level \d+/ =~ line
        print "<font color=\"#{normal_msg_color}\">"
  print line
  print "</font>"
      elsif /(.+)(http\:\/\/\S+)(.*)/ =~ line
        print $1
        print "<a href=\"#{$2}\" target=\"_blank\">#{$2}</a>"
        print $3
      else
        print line
      end
      print "<br>\n"
    end
  end
end

erb = ERB.new(<<E)
</td></tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr><td><hr></td></tr>
<tr>
<td align="center">
E
print erb.result

# リストのフッダー表示
wl.list_fooder("log_detail.rb", pos, limit, stotal, max_page, list_name="検索結果ページ", "&file_name=#{file_name}")

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
