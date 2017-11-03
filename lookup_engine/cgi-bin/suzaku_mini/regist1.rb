#!/ruby/bin/ruby

require 'cgi'
require 'cgi/session'
require 'nkf'
require 'erb'
require 'mysql'

# Suzaku 共通コンスタント／ライブラリ
require 'lib/constant'
require 'lib/suzaku_lib'
require 'lib/suzaku_weblib'
include Suzaku

# ----------------------------------------------------------------------------
# メイン処理
# ----------------------------------------------------------------------------

# CGI/Session のオープン
cgi = CGI.new

# 初期設定
cf = Config.new(Local_conf_file)
host = cf.parm["host"]
userid = cf.parm["userid"]
password = cf.parm["password"]
database = cf.parm["database"]
max_page = 20
first_f = false

# url
url = cgi.params["url"][0]

# mail address
mail = cgi.params["mail"][0]

# 推薦データの登録

msg = header = nil
begin
  if /^http:\/\/\S+/ =~ url
    ## 指定された url のサイトに接続する
    http = Http.new
    http.set_url(url.untaint)
    ac = http.test
    if ac < 0
      msg = "指定されたURLにアクセスできません。\n"
      raise 
    end
    # サイト名に'/'が付いていない場合は付加する
    url = http.get_url
  else
    msg = "URLが指定されていないか、形式が間違っています。\n"
    raise
  end
  if !(/\S+@\S+/ =~ mail)
    msg = "メールアドレスが指定されていないか、形式が間違っています。\n"
    raise
  end
  # データベースのオープン
  db = Mysql::new(host, userid, password, database)
  db.query("SET NAMES utf8")
  # insert regist
  db.query("INSERT INTO regist SET log_id=NULL,url='#{Mysql::quote url}',mail_address='#{Mysql::quote mail}',regist_time=NOW()")
  # データベースのクローズ
  db.close
  # メッセージ出力
  msg = "<b>サイトの推薦を受け付けました。ありがとうございました。</b>"
rescue
  msg = "内部処理エラーが発生しました。<br>#{$@}:#{$!}\n"
end


header(cgi, cf)
menubar(cgi, cf)

erb = ERB.new(<<E)
<center>

<table width="600" border="0" cellspacing="0">
<tr>
<td><br>
<font size="+1"><b>■ サイトの推薦結果</b></font>
<hr>
</td>
</tr>
</table>

<table width="600" border="0" cellspacing="0">
<tr><td>
<%= msg %>
</td></tr>
</table>

<table width="500" border="0" cellspacing="2">
<tr><td>
<table>
<tr>
<td>推薦したいサイトのURL: </td><td><%=url%></td>
</tr>
<tr>
<td>推薦者のメールアドレス: </td><td><%=mail%></td>
</table>
</td></tr>
</table>

<table width="600" border="0" cellspacing="0">
<tr>
<td>
<hr>
<a href="regist.rb">戻る</a>
</td>
</tr>
</table>

</center>
E
print erb.result(binding)

footer(cgi, cf)