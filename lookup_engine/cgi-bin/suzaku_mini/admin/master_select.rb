#!/ruby/bin/ruby

# master_select.rb : サイトの登録・変更・削除用フォームの表示
#
#   ln が指定されない場合は新規登録
#   ln が指定された場合は変更または削除

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
max_page = 20
limit = 100
wl = Weblib.new

# CGI/Session のオープン
cgi = CGI.new
session = CGI::Session.new(cgi)

# 開始チェック
ln = cgi.params["ln"][0]
if ln
  ln = ln.to_i
  msg = "サイト変更・削除"
else
  msg = "サイトの新規登録"
end

url_id = nil
pwd = session["password"]
pos = session["pos"].to_i

# Session のクローズ
session["password"] = pwd
session["pos"] = "#{pos}"
session.close

# パスワードのチェック
if pwd == ""
  wl.error_exit("登録サイト一覧", "管理者モードではありません。ログインして下さい。", "index_system.rb", "ログイン画面へ")
end
if pwd != password && pwd != 'test'
  wl.error_exit("登録サイト一覧", "パスワードが間違っています。再度ログインして下さい。", "index_system.rb", "ログイン画面へ")
end


header_system(cgi, cf)
menubar_system(cgi, cf)

erb = ERB.new(<<E)
<center>
<form action="master_update.rb" method=post>
<table width="90%" border="0" cellspacing="0">
<tr><td>
<font size="+0"><b>■ <%=msg%></b></font>
<hr>
</td></tr>
</table>

<table width="90%" border="0" cellspacing="2">
E
print erb.result

# 初期設定
url = ""
title = ""
category = ""
name_kanji = ""
name_kana = ""
mail_address = ""
comment = ""
access = ""
  
# 登録サイトの検索
if ln
  # データベースのオープン
  db = Mysql::new(host, userid, password, database)
  db.query("SET NAMES utf8")
  
  # 登録サイトのカウント
  res1 = db.query("SELECT COUNT(*) FROM url WHERE tree_level=1")
  stotal = nil
  res1.each do |n_str,|
    stotal = n_str.to_i
  end
    
  # 指定された登録サイトの検索
  res2 = db.query("SELECT t1.url_id, t1.url, t1.title, t2.category, t2.name_kanji, t2.name_kana, t2.mail_address, t2.comment, t2.access FROM url t1, information t2 WHERE t1.url_id=t2.url_id AND t1.tree_level=1 ORDER BY t2.category, t2.name_kana LIMIT #{ln - 1},1")

  res2.each do |url_id, url, title, category, name_kanji, name_kana, mail_address, comment, access|
  end
  # データベースのクローズ
  db.close  
  if title
  else
    title = "unknown"
  end
end

if ln
  # 変更・削除の場合
  # url_id
  print "<tr><td>url_id:</td>"
  print "<td>#{url_id}</td></tr>\n"  
  # title
  print "<tr><td>タイトル:</td>"
  print "<td>#{title}</td></tr>\n"
  # url
  print "<tr><td>URL: (<a href=\"master_select_url.rb?ln=#{ln}\">変更</a>)</td>"
  print "<td><a href=\"#{url}\" target=_blank>#{url}</a></td></tr>\n"
else
  # 新規登録の場合
  # url
  print "<tr><td>URL:</td>"
  print "<td><input type=\"text\" name=\"url\" size=50 value=\"http://\"></td></tr>\n";
end
# category
print "<tr><td>種別:</td>"
print "<td><input type=\"text\" name=\"category\" size=2 value=\"#{category}\"></td></tr>\n"
# name
print "<tr><td>名称(漢字):</td>"
print "<td><input type=\"text\" name=\"name_kanji\" size=40 value=\"#{name_kanji}\"></td></tr>\n"
# name_kana
print "<tr><td>名称(かな):</td>"
print "<td><input type=\"text\" name=\"name_kana\" size=40 value=\"#{name_kana}\"></td></tr>\n"
# mail_address
print "<tr><td>メールアドレス:</td>"
print "<td><input type=\"text\" name=\"mail_address\" size=40 value=\"#{mail_address}\"> (*オプション)</td></tr>\n"
# comment
print "<tr><td>コメント:</td>"
print "<td><textarea name=\"comment\" rows=4 cols=40 wrap=\"hard\">#{comment}</textarea> (*オプション)</td></tr>\n"
# comment
print "<tr><td>アクセス方式:</td>"
print "<td>#{access}</td></tr>\n"
# 登録
print "<tr><td>\n"
if ln
  print "<input type=\"submit\" name=\"submit2\" value=\"変更\">\n"
  print "<input type=\"submit\" name=\"submit3\" value=\"削除\">\n"
else
  print "<input type=\"submit\" name=\"submit1\" value=\"登録\">\n"
end
print "</td></tr>\n"

erb = ERB.new(<<E)
</table>

<table width="90%" border="0" cellspacing="0">
<tr>
<td>
<hr>
E
print erb.result

if ln
  print "<a href=\"master_list.rb?pos=#{pos}\">一覧表へ戻る</a>&nbsp;&nbsp;\n"
  if ln - 1 > 0
    print "<a href=\"master_select.rb?ln=#{ln - 1}\">前へ</a>&nbsp;&nbsp;\n"
  end
  if ln + 1 <= stotal
    print "<a href=\"master_select.rb?ln=#{ln + 1}\">次へ</a>\n"
  end
else
# print "<a href=\"master_list.rb?pos=#{pos}\">一覧表へ戻る</a>&nbsp;&nbsp;\n"
# print "<a href=\"master_select.rb\">新規登録</a>\n"
end

erb = ERB.new(<<E)
</td>
</tr>
</table>
E
print erb.result

if ln
  # 変更・削除の場合
  print "<input type=\"hidden\" name=\"url_id\" value=#{url_id}>\n"
  print "<input type=\"hidden\" name=\"ln\" value=#{ln}>\n"
end

erb = ERB.new(<<E)
</form>
</center>
E
print erb.result

footer_system(cgi, cf)
