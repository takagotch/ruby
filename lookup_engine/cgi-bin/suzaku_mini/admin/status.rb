#!/ruby/bin/ruby

# status.rb : システム状況の表示

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
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 開始チェック
pwd = session["password"]

# Session のクローズ
session["password"] = pwd
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("システム状況", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("システム状況", "パスワードが間違っています。再度ログインして下さい。", "index_system.rbl", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ システム状況</b></font>
<hr>
</td></tr>
<tr>
<td>
<p>
E
print erb.result

# データベースのオープン
db = Mysql::new(host, userid, password, database)
db.query("SET NAMES utf8")

erb = ERB.new(<<E)
<ul>
<li><b>登録完了ページ</b>
<ul>
E
print erb.result

# urlのカウント
res1 = db.query("SELECT tree_level, count(*) FROM url GROUP BY tree_level")
stotal = 0
res1.each do |lvl, n_str,|
  n = n_str.to_i
  stotal += n
  print "<li>Level #{lvl} -- #{n}\n"
end
print "<li>Total -- #{stotal}\n"

erb = ERB.new(<<E)
</ul>
<p>
<li><b>登録エラーページ</b>
<ul>
E
print erb.result

# urlのカウント
res1 = db.query("SELECT tree_level, count(*) FROM url WHERE response != '000'AND response != '200' GROUP BY tree_level")
stotal = 0
res1.each do |lvl, n_str,|
  n = n_str.to_i
  stotal += n
  print "<li>Level #{lvl} -- #{n}\n"
end
print "<li>Total -- #{stotal}\n"

erb = ERB.new(<<E)
</ul>
<p>
<li><b>キーワード数</b>
<ul>
E
print erb.result

# キーワードのカウント
res1 = db.query("SELECT count(*) FROM keyword")
stotal = 0
res1.each do |n_str,|
  stotal = n_str.to_i
end
print "<li>Total -- #{stotal}\n"

erb = ERB.new(<<E)
</ul>
</ul>
<hr>
E
print erb.result

# データベースのクローズ
db.close

erb = ERB.new(<<E)
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
