#!/ruby/bin/ruby

# このシステムについて

require 'cgi'
require 'erb'
require 'lib/constant'
require 'lib/suzaku_lib'
require 'lib/suzaku_weblib'
include Suzaku

cf = Config.new(Local_conf_file)
site_name = cf.parm["site_name"]
image_file_directry = cf.parm["image_file_directry"]

cgi = CGI.new

header(cgi, cf)
menubar(cgi, cf)

erb = ERB.new(<<E)
<div align="center">
  <table width="600" border="0" cellspacing="0 align="center">
    <tr>
      <td><br>
      <font size="+1"><b>■ このシステムについて</b></font>
      <hr>
      </td>
    </tr>
    <tr> 
      <td> 
        <!-- ここにシステムの説明を記述して下さい -->
      </td>
    </tr>
    <tr> 
      <td> 
        <hr>
      </td>
    </tr>
    <tr> 
      <td> 
        <div align="center"><a href="index.rb">HOME</a> </div>
      </td>
    </tr>
  </table>
</div>
E

print erb.result

footer(cgi, cf)

