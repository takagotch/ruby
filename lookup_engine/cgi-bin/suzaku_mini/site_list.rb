#!/ruby/bin/ruby

require 'cgi'
require 'nkf'
require 'erb'
require 'mysql'

# Suzaku 共通コンスタント／ライブラリ
require 'lib/constant.rb'
require 'lib/suzaku_lib.rb'
require 'lib/suzaku_weblib.rb'
include Suzaku

# 初期設定
cf = Config.new(Local_conf_file)
image_file_directry = cf.parm["image_file_directry"]

category = Hash.new
cf.parm.keys.sort.each do |x|
  if /\A\d\d\Z/ =~ x
    category[x] = cf.parm[x]
  end
end

max_page = 20
limit = 100
wl = Weblib.new

# CGI のオープン
cgi = CGI.new

# 開始チェック
pos = cgi.params["pos"][0]
if pos
  pos = cgi.params["pos"][0].to_i
else
  pos = 1
end

type = cgi.params["type"][0]
if type
  type = cgi.params["type"][0]
else
  type = '01'
end


header(cgi, cf)
menubar(cgi, cf)

erb = ERB.new(<<E)
<center>
  <table width="600" border="0" cellspacing="0">
    <tr>
      <td><br>
      <font size="+1"><b>■ 検索対象サイト</b></font>
      <hr>
      </td>
    </tr>
  </table>

  <table width="600" border="0" cellspacing="0">
    <tr> 
      <td> 
        <br>
          このシステムは、以下のサイトを検索対象にしています。</p>
        <ul>
E
print erb.result

  category.keys.sort.each do |k|
    print "          <li><a href=\"site_list1.rb?type=#{k}\">#{category[k]}のホームページ</a></li>\n"
  end

erb = ERB.new(<<E)
        </ul>
      </td>
    </tr>
    <tr> 
      <td> 
        <hr>
      </td>
    </tr>
    <tr>
      <td>
        <div align="center">
          <a href="index.rb">HOME</a>
        </div>
      </td>
    </tr>
  </table>
</center>
E
print erb.result

footer(cgi, cf)
