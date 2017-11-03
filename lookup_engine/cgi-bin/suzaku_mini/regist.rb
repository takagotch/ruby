#!/ruby/bin/ruby

# サイトの推薦

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

<div align="center">
  <table width="600" border="0" cellspacing="0">
    <tr>
      <td><br>
      <font size="+1"><b>■ サイトの推薦</b></font>
      <hr>
      </td>
    </tr>
    <tr> 
      <td> 
        <p><br>
          このシステムの検索対象にしたいサイトを推薦することができます。<br>
        </p>
        <form action="regist1.rb" method=post>
          <table border="0" cellspacing="2" align="center">
            <tr> 
              <td>推薦したいサイトのURL：</td>
              <td> 
                <input type="text" name="url" size="40" value="http://">
              </td>
            </tr>
            <tr> 
              <td>推薦者のメールアドレス：</td>
              <td> 
                <input type="text" name="mail" size="40">
              </td>
            </tr>
              <td>&nbsp;</td>
              <td> 
                <input type="submit" name="submit" value="送信">
              </td>
            </tr>
          </table>
        </form>
        </td>
    </tr>
    <tr>
      <td>
        <hr>
      </td>
    </tr>
    <tr>
      <td>
        <div align="center"><a href="index.rb">HOME</a></div>
      </td>
    </tr>
  </table>
</div>

E

print erb.result

footer(cgi, cf)

