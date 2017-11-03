#!/ruby/bin/ruby

require 'cgi'
require 'cgi/session'
require 'nkf'
require 'erb'

# Suzaku 共通コンスタント／ライブラリ
require '../lib/constant'
require '../lib/suzaku_lib'
require '../lib/suzaku_weblib.rb'
include Suzaku

# 初期設定
cf = Config.new("../" + Local_conf_file)
password = cf.parm["password"]
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 初期設定

# 開始チェック
pwd = session["password"]

# Session のクローズ
session["password"] = ""
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("ログオフ", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("ログオフ", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<center>
  <b>--- 管理者モードを終了しました ---</b><br>
<br>
<a href="../index.rb">HOME</a>
</center>
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
