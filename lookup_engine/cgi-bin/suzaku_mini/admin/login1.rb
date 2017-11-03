#!/ruby/bin/ruby

# ログイン処理

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
site_name = cf.parm["site_name"]
image_file_directry = cf.parm["image_file_directry"]

password = cf.parm["password"]
if cf.parm["test_mode"]
  test_mode = cf.parm["test_mode"]
else
  test_mode = false
end
max_page = 20
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 初期設定
pwd = cgi.params["password"][0]

# パスワードのチェック
if pwd == password || (test_mode && pwd == 'test')
  session["password"] = pwd
  session.close
else
  session["password"] = ""
  session.close
  wl.error_exit("ログイン", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end


header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<center>
  <b>--- 管理者モードに入りました ---</b><br>
</center>
</td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
