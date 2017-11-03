#!/ruby/bin/ruby

# setup.rb : システム設定

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
tmp_dir = cf.parm["tmp_dir"]
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
  wl.error_exit("システム管理", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.debug("password", password, "pwd", pwd)
  wl.error_exit("システム管理", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<br>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ システム管理</b></font>
<hr>
</td></tr>
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<ul>
<li><a href="setup1.rb?function=8">インターネットの巡回を停止</a><br>
<br>
<li><a href="setup1.rb?function=1">データベースの作成</a>
<li><a href="setup1.rb?function=3">テーブルの作成</a><br>
<br>
<li><a href="setup1.rb?function=5">登録サイトのバックアップ</a>
<li><a href="setup1.rb?function=6">登録サイトの復元</a><br>
<br>
<li><a href="setup1.rb?function=4">テーブルの削除</a>
<li><a href="setup1.rb?function=2">データベースの削除</a>
</ul>
<hr>
</td>
</tr>
</table>
E
print erb.result

footer_system(cgi, cf)
