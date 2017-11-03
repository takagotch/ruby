#!/ruby/bin/ruby

# ヘルプ

require 'cgi'
require 'erb'
require 'lib/constant'
require 'lib/suzaku_lib'
require 'lib/suzaku_weblib'
include Suzaku

cf = Config.new(Local_conf_file)
normal_msg_color = cf.parm["normal_msg_color"]

cgi = CGI.new

header(cgi, cf)
menubar(cgi, cf)

erb = ERB.new(<<E)

<div align="center">
  <table width="600" border="0" cellspacing="0">
    <tr>
      <td><br>
      <font size="+1"><b>■ ヘルプ</b></font>
      <hr>
      </td>
    </tr>
    <tr> 
      <td> 
        <h4><br>
          ●<a href="index.rb">スピード検索</a> </h4>
        <ol>
          <li><font color="<%= normal_msg_color %>">「キーワード」</font>欄に、検索に使用するキーワードを指定して、<font color="<%= normal_msg_color %>">「検索開始」</font>ボタンをクリックして下さい。</li>
        <li>ブランク（空白文字）で区切って複数のキーワードを指定することができます。この場合、すべてのキーワードを含むページを検索します（AND検索）。 
          </li>
        <LI>キーワードが複合語（例えば「政治経済」）の場合、基本語（「政治」と「経済」）に分解して、AND検索を行います。複合語を指定した場合の検索結果は、本来ヒットして欲しいもの以外のページもヒットすることがあります。 
</LI>
      </ol>
        <h4>●<a href="search_option.rb">検索オプション</a> </h4>
        <ol>
          <li><font color="<%= normal_msg_color %>">すべてのキーワードを含む(AND)</font> ・・・指定されたキーワードすべてを含むページを検索します。ブランク（空白文字）で区切って複数のキーワードを指定することができます（以下、2. 
            3. も同様）。</li>
          <li><font color="<%= normal_msg_color %>">いずれかのキーワードを含む(OR) </font>・・・指定されたキーワードのいずれかを含むページを検索します。</li>
          <li><font color="<%= normal_msg_color %>">これらのキーワードを含まない(NOT) </font>・・・1. 2. でヒットしたページのうち、ここに指定されたキーワードを含むページを除外します。</li>
          <li><font color="<%= normal_msg_color %>">このサイト内の文書のみ検索する(URL)</font> ・・・ 1. 2. 3. による検索結果のうち、指定されたURLで始まるページのみを表示します。</li>
          <li><font color="<%= normal_msg_color %>">1ページの表示件数</font>・・・検索結果を１ページに何件表示するかを指定します。</li>
          <li><font color="<%= normal_msg_color %>">表示順</font>・・・検索結果を表示する際の順番を指定します。</li>
          <li><font color="<%= normal_msg_color %>">表示形式</font> ・・・検索結果を表示する際の、表示形式を指定します。</li>
          <li>以上を指定して、<font color="<%= normal_msg_color %>">「検索開始」</font>ボタンをクリックして下さい。</li>
          <li>検索時には、1.(AND) または2.(OR)の少なくとも一方は指定する必要があります。3.(NOT)のみ指定すると、検索エラーになります</li>
        </ol>
        <p>　</p>
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
