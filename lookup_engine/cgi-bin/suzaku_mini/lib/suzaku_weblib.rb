require 'cgi'
require 'cgi/session'
require 'erb'

# module Suzaku start
module Suzaku

class Weblib

  # ---------------------------------------------------
  # エラーメッセージ出力 (eruby / mod_ruby) 
  # ---------------------------------------------------

  def error_exit(title, errmsg, link, linkmsg, color="#CC0000")
    cgi = CGI.new
    print cgi.header(Http_header)

    erb = ERB.new(<<E)
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head><title>#{title}</title>
</head>
<body>
  <center>
    <font color=\"#{color}\"><b>--- #{errmsg} ---</b></font>
    <br>
    <br>
    <a href=\"#{link}\">#{linkmsg}</a>
  </center>
</body>
</html>
E
    print erb.result
    exit
  end

  # ---------------------------------------------------
  # リストのヘッダー表示 
  # ---------------------------------------------------

  def list_header(url, pos, limit, stotal, query=nil)

    # query が指定されていない場合
    if query == nil
      query = ""
    end
    
    # 「前のページ」の表示
    if pos - limit > 0
      print "<a href=\"#{url}?pos=#{pos - limit}#{query}\">前のページ</a>&nbsp;\n"
    end
    
    # 「次のページ」の表示
    if pos + limit <= stotal
      print "<a href=\"#{url}?pos=#{pos + limit}#{query}\">次のページ</a>&nbsp;\n"
    end
  end

  # ---------------------------------------------------
  # リストのフッダー表示 
  # ---------------------------------------------------

  def list_fooder(url, pos, limit, stotal, max_page, list_name=nil, query=nil)

    # query が指定されていない場合
    if query == nil
      query = ""
    end
    
    # リスト名の表示
    if list_name == nil
      list_name = "Result"
    end
    print "#{list_name}:&nbsp;"

    # 各ページへのリンクの表示
    pos_s = ((pos / (limit * max_page.to_f)).floor) * (limit * max_page) + 1
    pn = (pos_s - 1) / limit + 1

    pos_b = pos_s - (limit * max_page)
    if pos_b < 1
      pos_b = 1
    end

    pos_n = pos_s + (limit * max_page)
    
    # 前リストへのリンクの表示
    if pn > 1
      print "<a href=\"#{url}?pos=#{pos_b}#{query}\">&lt;&lt;</a>&nbsp;&nbsp;\n"
    end
    
    # 各ページへのリンクの表示
    (1..max_page).each do |ctr|
      print "<a href=\"#{url}?pos=#{pos_s}#{query}\">#{pn + ctr - 1}</a>&nbsp;\n"
      pos_s += limit
      if pos_s > stotal
        break
      end
    end
   
    # 後リストへのリンクの表示
    if pos_s < stotal
      print "<a href=\"#{url}?pos=#{pos_n}#{query}\">&gt;&gt;</a>&nbsp;&nbsp;\n"
    # print "more..\n"
    end
  end

  # ---------------------------------------------------
  # デバッグ出力 (eruby / mod_ruby) 
  # ---------------------------------------------------

  def debug(e1, e2=nil, e3=nil, e4=nil, e5=nil, e6=nil)
    cgi = CGI.new
    print cgi.header(Http_header)
    erb = ERB.new(<<E)
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head><title>debug</title>
</head>
<body>
  <center>
    #{e1}<br>
    #{e2}<br>
    #{e3}<br>
    #{e4}<br>
    #{e5}<br>
    #{e6}<br>
    <br>
  </center>
</body>
</html>
E
    print erb.result
    exit
  end

end

# ---------------------------------------------------
# HTML ヘッダー
# ---------------------------------------------------

def header(cgi, cf)
  site_name   = cf.parm["site_name"]
  text_color  = cf.parm["text_color"]
  bg_color    = cf.parm["bg_color"]
  link_color  = cf.parm["link_color"]
  alink_color = cf.parm["alink_color"]
  vlink_color = cf.parm["vlink_color"]

  print cgi.header(Http_header)

  erb = ERB.new(<<E)
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title><%= site_name %></title>
</head>
<body text="<%= text_color %>" bgcolor="<%= bg_color %>" link="<%= link_color %>" alink="<%= alink_color %>" vlink="<%= vlink_color %>" leftmargin="4" topmargin="4" marginwidth="4" marginheight="4">
E
  print erb.result(binding)
end

def header_system(cgi, cf)
  site_name = cf.parm["site_name"]
  text_color  = cf.parm["text_color"]
  bg_color    = cf.parm["bg_color"]
  link_color  = cf.parm["link_color"]
  alink_color = cf.parm["alink_color"]
  vlink_color = cf.parm["vlink_color"]

  print cgi.header(Http_header)

  erb = ERB.new(<<E)
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Maintenance Mode : <%= site_name %></title>
</head>
<body text="<%= text_color %>" bgcolor="<%= bg_color %>" link="<%= link_color %>" alink="<%= alink_color %>" vlink="<%= vlink_color %>" leftmargin="4" topmargin="4" marginwidth="4" marginheight="4">
E
  print erb.result(binding)
end

# ---------------------------------------------------
# メニューバー
# ---------------------------------------------------

def menubar(cgi, cf)
  image_file_directry = cf.parm["image_file_directry"]

  erb = ERB.new(<<E)
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
<tr> 
  <td> <img src="<%= image_file_directry %>title.jpg" width="422" height="44"></td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
<tr> 
  <td> 
    <hr>
  </td>
</tr>
<tr> 
  <td> 
    <div align="center"><font size="-1">■<a href="index.rb">HOME</a>　■<a href="whatsnew.rb">新着情報</a>　■<a href="about.rb">このシステムについて</a><a href="regist.rb"></a>　■<a href="search_option.rb">検索オプション</a>　■<a href="site_list.rb">検索対象サイト</a>　■<a href="regist.rb">サイトの推薦</a>　■<a href="help.rb">HELP</a></font></div>
  </td>
</tr>
<tr> 
  <td> 
    <hr>
  </td>
</tr>
</table>
E
  print erb.result(binding)
end

def menubar_system(cgi, cf)
  image_file_directry = cf.parm["image_file_directry"]

  erb = ERB.new(<<E)
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
<tr> 
  <td> <img src="<%= image_file_directry %>title-maintenance.jpg" width="425" height="44"></td>
</tr>
<tr> 
  <td> 
    <hr>
  </td>
</tr>
<tr> 
  <td> 
    <div align="center"><font size="-1">■<a href="index_system.rb">ログイン</a>　■<a href="master_select.rb">サイトの新規登録</a>　■<a href="master_list.rb">登録サイト一覧</a>　■<a href="regist_list.rb">推薦サイト一覧</a>　■<a href="searchlog_list.rb">検索ログ</a>　■<a href="log_list.rb">巡回ログ</a>　■<a href="status.rb">システム状況</a>　■<a href="setup.rb">システム管理</a>　■<a href="logoff.rb">ログオフ</a>　</font></div>
  </td>
</tr>
<tr> 
  <td> 
    <hr>
  </td>
</tr>
</table>
E
  print erb.result(binding)
end

# ---------------------------------------------------
# HTML フッター
# ---------------------------------------------------

def footer(cgi, cf)

  erb = ERB.new(<<E)
</body>
</html>
E
  print erb.result(binding)
end

def footer_system(cgi, cf)

  erb = ERB.new(<<E)
</body>
</html>
E
  print erb.result(binding)
end

# module Suzaku end 
end
