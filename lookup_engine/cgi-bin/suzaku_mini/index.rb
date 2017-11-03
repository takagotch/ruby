#!/ruby/bin/ruby

# 検索画面

require 'cgi'
require 'erb'
require 'lib/constant'
require 'lib/suzaku_lib'
require 'lib/suzaku_weblib'
include Suzaku

cf = Config.new(Local_conf_file)
image_file_directry = cf.parm["image_file_directry"]

cgi = CGI.new

header(cgi, cf)
menubar(cgi, cf)

erb = ERB.new(<<E)
<table width="600" border="0" cellspacing="2" cellpadding="2" align="center">
  <tr> 
    <td> 
      <form action="search1.rb" method=post>
        <input type="hidden" name="start" value="1">
        <table border="0" cellspacing="2" align="center">
          <tr> 
            <td> キーワード：　</td>
            <td> 
              <input type="text" name="key_and" size="40">
              &nbsp;&nbsp; 
              <input type="submit" name="submit" value="検索開始">
            </td>
          </tr>
        </table>
      </form>
    </td>
  </tr>
  <tr> 
    <td> 
      <div align="center"> <br>
        <img src="<%= image_file_directry %>main.jpg"> <br>
        <br>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <hr>
    </td>
  </tr>
</table>
<table width="600" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
      <TD width="244"> 
      <div align="left"></div>
    </TD>
      <TD width="115"> 
      <div align="center"><a href="index.rb">HOME</a></div>
    </TD>
      <TD width="241"> 
      <div align="right">powered by <font size="-1"><a href="http://hoshizawa.no-ip.com/suzaku/" target="_blank">SUZAKU</a>　[<a href="admin/index_system.rb">管理者モード</a>]</font></div>
    </TD>
    </tr>
</table>
E
print erb.result

footer(cgi, cf)
