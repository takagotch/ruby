#!/ruby/bin/ruby

# 管理者画面

require 'cgi'
require 'cgi/session'
require 'nkf'
require 'erb'

# Suzaku 共通コンスタント／ライブラリ
require '../lib/constant'
require '../lib/suzaku_lib'
require '../lib/suzaku_weblib'
include Suzaku

cf = Config.new("../" + Local_conf_file)

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# Session のクローズ
session["password"] = ""
session.close

header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<table width="90%" border="0" cellspacing="2">
<tr>
  <td> 
    <div align="center">管理者モードに入るには、パスワードを入力して下さい。 </div>
    <form action="login1.rb" method=post>
      <div align="center">
        <p>
          パスワード： 
          <input type="password" name="password" size="20">
          &nbsp;&nbsp; 
          <input type="submit" name="submit" value="実行">
          <br>
          <br>
        </p>
        <p><a href="../index.rb" target="_top">HOME</a> </p>
      </div>
    </form>
  </td>
</tr>
</table>
</center>
E
print erb.result

footer_system(cgi, cf)
