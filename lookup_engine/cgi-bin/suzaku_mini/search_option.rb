#!/ruby/bin/ruby

# 検索オプション

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
  <table width="600" border="0" cellspacing="0" align="center">
    <tr>
      <td><br>
      <font size="+1"><b>■ 検索オプション</b></font>
      <hr>
      </td>
    </tr>
    <tr> 
      <td> 
        <form action="search1.rb?" method=post>
          <input type="hidden" name="start" value="1">
          <table border="0" cellspacing="2" align="center">
            <tr> 
              <td>すべてのキーワードを含む(AND) ：</td>
              <td>
                <input type="text" name="key_and" size="30">
                &nbsp;&nbsp;
                <input type="submit" name="submit2" value="検索開始">
              </td>
            </tr>
            <tr> 
              <td>いずれかのキーワードを含む(OR) ：</td>
              <td>
                <input type="text" name="key_or" size="30">
              </td>
            </tr>
            <tr> 
              <td>これらのキーワードを含まない(NOT) ：</td>
              <td>
                <input type="text" name="key_not" size="30">
              </td>
            </tr>
            <tr> 
              <td>このサイト内の文書のみ検索する(URL)：</td>
              <td> 
                <input type="text" name="url" size="30" value="http://">
              </td>
            </tr>
            <tr> 
              <td>1ページの表示件数 ：</td>
              <td> 
                <select name="limit">
                  <option value="10">10件 </option>
                  <option value="20">20件 </option>
                  <option value="30">30件 </option>
                  <option value="50">50件 </option>
                  <option value="100">100件 </option>
                </select>
              </td>
            </tr>
            <tr> 
              <td>表示順 ：</td>
              <td> 
                <select name="order">
                  <option value="1">スコア順(大きいものから) 
                  <option value="2">日付順(新しいものから) 
                </select>
              </td>
            </tr>
            <tr> 
              <td>表示形式 ：</td>
              <td> 
                <select name="style">
                  <option value="1">タイトルと要約 
                  <option value="2">タイトルのみ 
                </select>
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
