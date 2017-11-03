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
host = cf.parm["host"]
userid = cf.parm["userid"]
password = cf.parm["password"]
database = cf.parm["database"]
log_dir = cf.parm["log_dir"].untaint

max_page = 10
limit = 25
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 開始チェック
pwd = session["password"]

pos = cgi.params["pos"][0]
if pos
  pos = pos.to_i
  pos = ((pos / limit.to_f).floor) * limit + 1
  first = false
else
  pos = 1
  first = true
end

detail = cgi.params["detail"][0]
if detail
  detail = true
else
  detail = false
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

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ 巡回ログ</b></font>
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

# ログファイル数のカウント
stotal = 0
Dir.glob("../bin/#{log_dir}/*") do |f|
  stotal += 1
end

# 最後のログを表示
# if first
#   pos = ((stotal / limit).to_f.floor) * limit + 1
# end

# リストのヘッダー表示
wl.list_header("log_list.rb", pos, limit, stotal)

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
Dir.glob("../bin/#{log_dir}/*").sort.reverse.each do |f|
  lc += 1
  if lc >= ln && lc < ln + limit
#   print "#{lc}:&nbsp;&nbsp;"
    print "<a href=\"log_detail.rb\?file_name=#{File.basename(f)}\">"
    print File.basename(f)
    print "</a><br>\n"
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
wl.list_fooder("log_list.rb", pos, limit, stotal, max_page, list_name="検索結果ページ")

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
