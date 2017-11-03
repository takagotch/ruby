# ----------------------------------------------------------------------------
# robot.rb : HTMLファイルをparseして、キーワードを抽出する
# ----------------------------------------------------------------------------

require 'socket'
require 'net/http'
require 'kconv'
require 'parsedate'
require 'mysql'
require 'chasen'

require '../lib/constant'
require '../lib/suzaku_lib'
include Suzaku

# ----------------------------------------------------------------------------
# 定数
# ----------------------------------------------------------------------------

# タグによるランク設定(タグは必ず小文字で記述)
Html_tag = {
  "title"       => 16,
  "h1"          =>  8,
  "h2"          =>  7,
  "h3"          =>  6,
  "h4"          =>  5,
  "h5"          =>  4,
  "h6"          =>  3,
  "a"           =>  4,
  "strong"      =>  2,
  "em"          =>  2,
  "bold"        =>  2,
  "keywords"    => 32,
  "description" => 32,
}

Modname = 'robot'
Agentname = 'suzaku_mini'
Regist_suffix = 'htm|html|cgi|php|rhtml|rb'
Title_len = 200
Abstract_len = 400

# ----------------------------------------------------------------------------
# WebDB : WebDB クラス
# ----------------------------------------------------------------------------

class WebDB
  attr_reader :dbh

  # 初期化
  def initialize
    @dbh = nil
  end
    
  # データベースのオープン
  def open(host, userid, password, database)
    # MySQLとのコネクション確立
    @dbh = Mysql::new(host, userid, password, database)
    @dbh.query("SET NAMES utf8")
  end

  # データベースのクローズ
  def close()
    # MySQLとのコネクション切断
    @dbh.close
  end

  # keyword の登録
  def insert_keyword(word, url_id, n)
    # keyword の追加
    begin
      @dbh.query("INSERT INTO keyword (keyword,url_id,score,count) VALUES ('#{Mysql::quote word}',#{url_id},#{n},1)")
    rescue MysqlError
      if $!.errno != 1062
        # 重複レコード以外の場合
        raise
      end
    end
    
    # 重複レコードの場合、keyword の更新
    res = @dbh.query("SELECT score,count FROM keyword WHERE keyword='#{Mysql::quote word}' AND url_id=#{url_id}")
    res.each do |score, count|
      @dbh.query("UPDATE keyword SET score=#{score.to_i + n},count=#{count.to_i + 1} WHERE keyword='#{Mysql::quote word}' AND url_id=#{url_id}")
    end
  end

  # keyword の削除
  def delete_keywords(url_id)
    @dbh.query("DELETE FROM keyword WHERE url_id=#{url_id}")
  end

  # url の登録
  def insert_url(url, next_level, top_url_id)
    begin
      @dbh.query("INSERT INTO url (url_id,url,tree_level,top_url_id,registed,last_modified,last_parsed) VALUES (NULL,'#{Mysql::quote url}',#{next_level},#{top_url_id},NOW(),'0000-00-00 00:00:00','0000-00-00 00:00:00')")
    rescue MysqlError
      if $!.errno != 1062
        # 重複レコード以外の場合
        raise
      end
    end
  end

  # url の削除
  def delete_url(url_id)
    @dbh.query("DELETE FROM url WHERE url_id=#{url_id}")
  end  

  # url に sid をセット
  def update_url_sid(url_id, sid)
    @dbh.query("UPDATE url SET sequence_id=#{sid} WHERE url_id=#{url_id}")
  end

  # url の select (order url_id)
  def select_url_1(level)
    res = @dbh.query("SELECT url_id, url FROM url WHERE tree_level=#{level} ORDER BY url_id")
  end

  # url の select (order sid, url_id)
  def select_url_2(level)
    res = @dbh.query("SELECT sequence_id, url_id, url, tree_level, top_url_id, last_modified, last_parsed, response FROM url WHERE tree_level=#{level} ORDER BY sequence_id, url_id")
  end

  # url の select (url_id)
  def select_url_url(url_id)
    res = @dbh.query("SELECT url FROM url WHERE url_id='#{url_id}'")
    data = nil
    res.each do |n_str,|
      data = n_str
    end
    return data
  end

  # information -- access の select (url_id)
  def select_information_access(url_id)
    res = @dbh.query("SELECT access FROM information WHERE url_id=#{url_id}")
    data = nil
    res.each do |access,|
      data = access.to_i
    end
    return data
  end

  # url に更新タイムスタンプをセット
  def update_last_parsed(url_id, mtime, ptime, response)
    mstr = to_sql_datetime(mtime)
    pstr = to_sql_datetime(ptime)
    @dbh.query("UPDATE url SET last_modified=\"#{mstr}\",last_parsed=\"#{pstr}\",response='#{response}' WHERE url_id=#{url_id}")
  end

  # url に更新タイムスタンプをセット
  def update_last_checked(url_id, ptime, response)
    pstr = to_sql_datetime(ptime)
    @dbh.query("UPDATE url SET response='#{response}',last_parsed=\"#{pstr}\" WHERE url_id=#{url_id}")
  end

  # url に title をセット
  def update_url_title(url_id, title_str)
    @dbh.query("UPDATE url SET title='#{Mysql::quote title_str}' WHERE url_id=#{url_id}")
  end

  # url に 要約をセット
  def update_url_abstract(url_id, abstract_str)
    @dbh.query("UPDATE url SET abstract='#{Mysql::quote abstract_str}' WHERE url_id=#{url_id}")
  end

  # url に response をセット
  def update_url_set_response(url_id, code)
    @dbh.query("UPDATE url SET response='#{code}',last_parsed=NOW() WHERE url_id=#{url_id}")
  end
  
  # MySQLのdatetime型文字列をRubyのTime型に変換
  def from_sql_datetime(str)
    begin
      (year, month, day, hour, min, sec,), = str.scan(/(\d+)\-(\d+)\-(\d+)\s+(\d+)\:(\d+)\:(\d+)/)
      tm = Time.mktime(year, month, day, hour, min, sec)
      return tm
    rescue
      return nil
    end
  end

  # MySQLのdatetime型文字列に変換
  def to_sql_datetime(tm)
    if tm
      return tm.strftime("%Y-%m-%d %H:%M:%S")
    else
      return "0000-00-00 00:00:00"
    end
  end

end

# ----------------------------------------------------------------------------
# Buffer : バッファ getc/ungetc クラス
# ----------------------------------------------------------------------------

class Buffer

  # 初期化
  def initialize(file = nil, size = 2048)
    @file = file
    @size = size
    @n = 0
    @i = 0
  end

  # セットアップ
  def setup(file)
    @file = file
    @n = 0
    @i = 0
  end
  
  # getc
  def getc
    if @i >= @n
      @buf = @file.read(@size)
      if @buf == nil
        return nil
      end
      @n = @buf.size
      @i = 0
    end
    c = @buf[@i]
    @i += 1
    return c
  end

  # ungetc
  def ungetc(c)
    if c == nil
      if @buf == nil
        return
      else
        log.e_msg("Buffer.ungetc", 1, "bad nil.")
      end
    end
    if @buf == nil
      @buf = " "
      @n = 1
      @i = 1
    end
    if @i == 0
      @buf = c.chr + @buf
      @n = @buf.size
    else
      @i -= 1
      @buf[@i] = c
    end
  end
end

# ----------------------------------------------------------------------------
# Parser : HTML 解析処理クラス
# ----------------------------------------------------------------------------

class Parser

  def initialize(log)
    @url = Url.new
    @buf = Buffer.new
    @log = log
  end
  
  # セットアップ
  def setup(dbh, fh, url_id, url, level, top_url_id, limit = false)
    @dbh = dbh
    @buf.setup(fh)
    @url_id = url_id
    @url.parse(url)
    @current_level = level
    @top_url_id = top_url_id
    @top_url = set_top_url(top_url_id) 
    @current_block = ["init"]
    @current_n = [1]
    @str = nil
    @style = false
    @script = false
    @title = false
    @header = false
    @abstract = ""
    @content = ""
    @noindex = @nofollow = false
    @limit_same_host = limit
  end

  # topページのディレクトリ名を求める
  def set_top_url(top_url_id)
    @log.debug("Parser.set_top_url")
    top_url = @dbh.select_url_url(top_url_id)
    (top_dir, top_file), = top_url.scan(/^(.*\/)(.*)$/)
    return top_dir
  end

  # 字句の読み込み
  def token()
    @log.debug("Parser.token")
    n = nil
    c = nil
    
    # コメントおよび空白文字をスキップ
    if !(skip_spaces_and_comments())
      return false
    end

    # 最初の文字が'<'か？
    n = @buf.getc()
    if n == nil
      return false
    end
    c = n.chr
    if c == '<'        
      @str = c
      # 最初の文字が'<'の場合
      # '>'が見つかるまで、読み込みを続ける
      while (n = @buf.getc()) do
        c = n.chr
        @str += c
        if c == '>'
          break
        end
      end
      @log.debug("[token T:#{@str}]")
    else
      @str = c
      # 最初の文字が'<'ではない場合
      # '<'が見つかるまで、読み込みを続ける
      while (n = @buf.getc()) do
        c = n.chr
        if c == '<'
          @buf.ungetc(n)
          break
        end
        @str += c
      end
      @log.debug("[token C:#{@str}]")
    end
    if n == nil
      return false
    else
      return true
    end
  end

  # 空白文字とコメントをスキップする
  def skip_spaces_and_comments()
    @log.debug("Parser.skip_spaces_and_comments")
    while true
      # 空白文字をスキップする
      while (n1 = @buf.getc()) do
        c = n1.chr
        if /\s/ =~ c
        else
          break
        end
      end
      if n1 == nil
        return false
      end
      c = n1.chr

      # 1番目の文字が'<'か？
      if n1 == nil || (n1 != nil && n1.chr != '<')
        @buf.ungetc(n1)
        return true
      end
      
      # 2番目の文字が'!'か?
      n2 = @buf.getc()
      if n2 == nil || (n2 != nil && n2.chr != '!')
        @buf.ungetc(n2)
        @buf.ungetc(n1)
        return true
      end
      
      # 3番目の文字が'-'か?
      n3 = @buf.getc()
      if n3 == nil || (n3 != nil && n3.chr != '-')
        @buf.ungetc(n3)
        @buf.ungetc(n2)
        @buf.ungetc(n1)
        return true
      end

      # 4番目の文字が'-'か?
      n4 = @buf.getc()
      if n4 == nil || (n4 != nil && n4.chr != '-')
        @buf.ungetc(n4)
        @buf.ungetc(n3)
        @buf.ungetc(n2)
        @buf.ungetc(n1)
        return true
      end

      # コメントの処理開始

      # '-'が見つかるまで、読み込みを続ける
      while (n5 = @buf.getc()) do
        if n5.chr != '-'
          next
        end

        # 2番目の文字が'-'か?
        n6 = @buf.getc()
        if n6 == nil
          break
        elsif n6.chr != '-'
    @buf.ungetc(n6)
          next
        end

        # 3番目の文字が'>'か?
        n7 = @buf.getc()
        if n7 == nil
          break
        elsif n7.chr != '>'
    @buf.ungetc(n6)
    @buf.ungetc(n7)
          next
        else
          # コメントの処理完了
          break
        end
      end

      if n5 == nil
        # コメントが終了する前にEOFとなった
        @log.e_msg("Parser.skip_spaces_and_comments", 1, "#{@url.url} [#{@url_id}] EOF reached before comennt close.")
        return false
      else
        next
      end
    end
  end

  # その他のタグの処理
  def tag()
    @log.debug("Parser.tag")
    # コメントの処理
    if /^<!--/ =~ @str
      @log.e_msg("Parser.tag", 1, "#{@url.url} [#{@url_id}] abnormal comment tag.")
      return
    end

    # タグの処理
    if /\w+/ =~ @str
      # タグを小文字に変換後、マッチング処理
      tagname = $&.downcase
      n1 = Html_tag[tagname]
      # ランク付け対象のタグか？
      if n1 != nil
        # ランク付け対象のタグの場合
        # 終了タグか？
        if /^<\// =~ @str
          # 終了タグならランクを復帰する
          @log.debug("TAG2:#{@current_n.last()}:#{@str}")
          if @current_block.last() != tagname
            @log.w_msg("Parser.tag", 2, "#{@url.url} [#{@url_id}] tag unmatch </#{@current_block.last()}>:</#{tagname}>")
          end
          if @current_block.size > 1
            @current_block.pop()
            @current_n.pop()
          else
            @log.w_msg("Parser.tag", 3, "#{@url.url} [#{@url_id}] end tag too much </#{tagname}>")
          end
        else
          # 開始タグならランクを設定する
          @current_block.push(tagname)
          @current_n.push(@current_n.last() + n1)
          @log.debug("TAG1:#{@current_n.last()}:#{@str}")
        end
      else
        # ランク付け対象外のタグの場合
        # 何もしない
        @log.debug("TAG3:#{@current_n.last()}:#{@str}")
      end
    end
    # style タグの処理
    if /^<\s*style\s*/i =~ @str
      @style = true
    end
    if /^<\s*\/\s*style\s*/i =~ @str
      @style = false
    end
    # script タグの処理
    if /^<\s*script\s*/i =~ @str
      @script = true
    end
    if /^<\s*\/\s*script\s*/i =~ @str
      @script = false
    end
    # title タグの処理
    if /^<\s*title\s*>/i =~ @str
      @title = true
    end
    if /^<\s*\/\s*title\s*>/i =~ @str
      @title = false
    end
    # h? タグの処理
    if /^<\s*h[1-6]\s*>/i =~ @str
      @header = true
    end
    if /^<\s*\/\s*h[1-6]\s*>/i =~ @str
      @header = false
    end
    # meta タグの処理
    if /^<\s*meta\s+/i =~ @str
      # robotsの処理
      if /name\s*=\s*\"\s*robots\s*\"\s+content\s*=\s*\"(.*?)\"/i =~ @str
        words = $1.split(/\s*,\s*/)
        @log.debug("robots:#{words[0]},#{words[1]}")
        if /noindex/i =~ words[0]
          @noindex = true
        end
        if /nofollow/i =~ words[1]
          @nofollow = true
        end
        @log.n_msg("#{@url.url} [#{@url_id}] robots:noindex(#{@noindex}),nofollow(#{@nofollow})")
      # keywords の処理
      elsif /name\s*=\s*\"\s*keywords\s*\"\s+content\s*=\s*\"(.*?)\"/i =~ @str
        words = $1.split(/\s*,\s*/)
        n1 = Html_tag["keywords"]
        # キーワードを登録する
        words.each do |wstr|
          @log.debug("keywords:#{n1}:#{wstr}")
          regist_keywords(wstr, n1)
          # 要約として保存する
          save_abstract(wstr + ' ')
        end
      # description の処理
      elsif /name\s*=\s*\"\s*description\s*\"\s+content\s*=\s*\"(.*?)\"/i =~ @str
        desc = $1
        n1 = Html_tag["description"]
        @log.debug("description:#{n1}:#{desc}")
        # キーワードを登録する
        regist_keywords(desc, n1)
        # 要約として保存する
        save_abstract(desc + ' ')
      elsif
        @log.debug("other...")
      end
    end
    # base タグの処理
    # 未実装
    #
    # リンクの処理(SRC)
    if /src\s*=\s*\"(.*?)\"/i =~ @str
      src = $1
      @log.debug("src:#{src}")
      # URLを登録する
      regist_url(src)
    end
    # リンクの処理(HREF)
    if /href\s*=\s*\"(.*?)\"/i =~ @str
      href = $1
      @log.debug("href:#{href}")
      # URLを登録する
      regist_url(href)
    end
    # alt タグの処理
    if /alt\s*=\s*\"(.*?)\"/i =~ @str
      alt = $1
      @log.debug("alt:#{@current_n.last()}:#{alt}")
      # キーワードを登録する
      regist_keywords(alt, @current_n.last())
    end
  end

  # 本文の処理
  def content()
    @log.debug("Parser.content")
    # puts "content()"
    @log.debug("CNTS:#{@current_n.last()}:#{@str}")
    # style sheet, script の記述は無視する
    if @style || @script
      return
    end
    # URL に title を登録する
    if @title
      title_str = jsubstr(@str, Title_len)
      @dbh.update_url_title(@url_id, title_str)
    end
    # 検索結果表示用に、URLのコンテンツを保存
    #     要約としてdescription, keyword, <h?></h?>を保存
    #     足りなければ文書の冒頭部分を保存
    if @header
      save_abstract(@str + ' ')
    else
      save_content(@str + ' ')
    end
    # キーワードを登録する
    regist_keywords(@str, @current_n.last())
    # puts "#{@str}"
  end

  # キーワードの登録
  def regist_keywords(str, n)
    @log.debug("Parser.regist_keywords : #{str},#{n}")
    # noindex が指定されていたら、索引化しない
    if @noindex
      return
    end
    # str の長さが0なら何もしない
    if str.size == 0
      return
    end
    
    # strを茶筌で解析する (UTF-8)
    Chasen.getopt("-F", "%m\t:%h\n", "-j", "-i", "w")
    @log.debug("Parser.regist_keywords Chasen.getopt")
    Chasen.sparse(str).each do |line|
      @log.debug("Parser.regist_keywords Chasen.sparse line:#{line}")
      if /^(\S+)\s+:(\d+)$/ =~ line
        @log.debug("keyword: #{$1} #{@url_id} #{n}")
        if n < 1
          @log.e_msg("Parser.regist_keywords", 1, "#{@url.url} [#{@url_id}] score < 1.")
        end
        @dbh.insert_keyword($1, @url_id, n)
      end
    end
    return
  end
  
  # 文字列の切り出し(日本語対応)
  def jsubstr(str, n)
    @log.debug("Parser.jsubstr")
    ca = str.scan(/./)
    res = ""
    i = 0
    ca.each do |c|
      l = c.length
      if i + l <= n
        res << c
      else
        break
      end
      i += l
    end
    return res
  end

  # 要約の保存
  def save_abstract(str)
    @log.debug("Parser.save_abstract")
    str.scan(/\s*(.*)\s*$/) do |s,|
      l1 = @abstract.length
      if l1 < Abstract_len
        l2 = s.length
        if l2 <= (Abstract_len - l1) 
          @abstract << s
        else
          @abstract << jsubstr(s, (Abstract_len - l1))
        end
      end
    end
  end

  # 文書の先頭部分の保存
  def save_content(str)
    @log.debug("Parser.save_content")
    @log.debug("save_content 1:#{str}")
    str.scan(/\s*(.*)\s*$/) do |s,|
      @log.debug("save_content 2:#{s}")
      l1 = @content.length
      if l1 < Abstract_len
        l2 = s.length
        if l2 <= (Abstract_len - l1) 
          @content << s
        else
          @content << jsubstr(s, (Abstract_len - l1))
    @log.debug("save_content 3:#{jsubstr(s, (Abstract_len - l1))}")
        end
      end
    end
  end    
      
  # URLの登録
  def regist_url(url)
    @log.debug("Parser.regist_url")
    # nofollow が指定されていたらリンクを追跡しない
    if @nofollow
      @log.debug("noffolow : #{url}")
      return
    end
    # 同一ページ内のリンクは登録しない
    if /^\#/ =~ url
      @log.debug("same page : #{url}")
      return
    end
    # 絶対パスに変換する
    abs_url = @url.convert_to_abs_path(url)
    # URLの同一ホスト内チェック
    if @limit_same_host
      if /#{@top_url}/ =~ abs_url
      else
        @log.debug("not same host : #{@top_url} #{@other_site} : #{abs_url}")
        return
      end
    end
    # URLを登録する
    if /\/$/ =~ abs_url || /\.(#{Regist_suffix})($|\?|\#)/ =~ abs_url
      # 絶対パスからfragmentを削除する
      (abs_url_without_frag, fragment), = abs_url.scan(/^([^\#]+)(\#.+)?/)
      @log.debug("#{url} #{abs_url} #{@current_level + 1}")
      if abs_url_without_frag.size < 250
        @dbh.insert_url(abs_url_without_frag, @current_level + 1, @top_url_id)
      else 
        @log.e_msg("Parser.regist_url", 1, "url length over : #{url} -> #{abs_url_without_frag}")
      end
    end
    @log.debug("regist_url end.")
    return
  end

  # パース処理
  def parse()
    @log.debug("Parser.parse")
    # puts "parse()"
    if /^</ =~ @str
      tag()
    else
      content()
    end
    eofsw = token()
  end

  # 終了処理
  def finish
    @log.debug("Parser.finish")
    # 要約をデータベースに保存
    str = @abstract
    l1 = str.length
    if l1 < Abstract_len
      l2 = @content.length
      if l2 <= (Abstract_len - l1) 
        str << @content
      else
        str << jsubstr(@content, (Abstract_len - l1))
      end
    end
    @dbh.update_url_abstract(@url_id, str)
  end
  
end

# ----------------------------------------------------------------------------
# Robot : robots.txt チェッククラス
# ----------------------------------------------------------------------------

class Robot

  # 初期化
  def initialize(log, agent = nil, dir = ".", bps = 2400)
    @log = log
    @agent = agent
    @host = nil
    @exist = false
    @allow = Array.new
    @disallow = Array.new
    @http = Http.new(@agent, dir)
    @fconv = FileConvert.new
    @url = Url.new("/")
    @dir = dir
    @bps = bps
  end

  # robots.txt の読み込み
  def get(host, ac = 0)
    @log.debug("Robot.get")
    # 設定済みの場合
    if @host == host
      return @exist
    end

    begin
      @host = host
      @exist = false
      @allow.clear
      @disallow.clear
    
      # URLで指定されたホストのrobots.txtをGET
      url = "http://" + host + "/robots.txt"
      @http.set_url(url, ac)
      @http.get

      while @http.code == '301' || @http.code == '302' || @http.code == '303' || @http.code == '304' 
        @log.n_msg("#{url} moverd. -> #{@http.location}")
        @http.set_url(@http.location)
        @http.get
      end

      # OK 以外であればエラー
      if @http.code != '200'
        raise  "rc:#{@http.code}"
      end

      # ローカルファイルをオープンする      
      fn = @http.dir + @http.local_file
      fh = File.open(fn)

      hit = false
      # robots.txt を読む
      fh.each do |line|
        # 空白行の場合
        if /^\s*$/ =~ line
          hit = false
          next
        end
        # User-Agent
        if /^\s*User-Agent:\s*(\S+)/ =~ line
          an = $1
          # 全ての User-Agent が対象
          if /\*/ =~ an
            @log.debug("Robot.get 1 : * -- #{an}")
            hit = true
            next
            # この User-Agent が対象
          elsif /#{an}/ =~ @agent
            @log.debug("Robot.get 2 : #{an} -- #{@agent}")
            hit = true
            next
            # 対象外
          else
            @log.debug("Robot.get 3 : #{an} -- #{@agent}")
            hit = false
            next
          end
        end
        # Disallow
        if hit
          if /\s*Disallow:\s*(\S+)/ =~ line
            @disallow.push($1)
            # 設定数のチェック
            if @disallow.size > 100
              @log.e_msg("Robot.get", 1, "#[url} disallow too much")
              break
            end
          end
        end
        # Allow
        if hit
          if /\s*Allow:\s*(\S+)/ =~ line
            @allow.push($1)
            # 設定数のチェック
            if @allow.size > 100
              @log.e_msg("Robot.get", 2, "#{url} allow too much")
              break
            end
          end
        end
      end

      #debug
      @disallow.each do |str|
        @log.debug("Robot.get Regist Array Disallow: #{str}")
      end
      @allow.each do |str|
        @log.debug("Robot.get Regist Array Allow: #{str}")
      end
      
      @exist = true

    rescue NameError
      # net/protocol.rb 内部エラーをリカバリーする
      @log.e_msg("Robot.get", 3, "#{url} #{$@}:#{$!}")
      @exist = false

    rescue
      # 例外処理
      if /rc\:404/ =~ $!
        if $message
          @log.n_msg("#{url} not found.")
        end
      elsif /(http:\/\/.+)rc\:/ =~ $!
        @log.e_msg("Robot.get", 4, "#{url} #{$@}:#{$!}")
      else
        @log.e_msg("Robot.get", 5, "#{url} #{$@}:#{$!}")
      end
      @exist = false
      
    ensure
      # ローカルファイルクローズ
      if fh
        fh.close
      end
      # ローカルファイル削除
      if File.exist?(@http.dir + @http.local_file)
        File.unlink(@http.dir + @http.local_file)
      end
      return @exist
    end
  end

  # robots.txtの制限に該当するかをチェック
  def check(url, ac = 0)
    @log.debug("Robot.check")
    # robots.txt をget
    @url.parse(url)
    if !(get(@url.host, ac))
      # robots.txt がない場合
      return true
    end

    # Allow
    @allow.each do |str|
      if /^#{str}/ =~ @url.abs_path
        @log.debug("Robot.check hit Allow: #{str} -- #{@url.abs_path}")
        return true
      end
    end
    # Disallow
    @disallow.each do |str|
      if /^#{str}/ =~ @url.abs_path
        @log.debug("Robot.check hit Disallow: #{str} -- #{@url.abs_path}")
        return false
      end
    end
    @log.debug("Robot.check other(Allow): #{@url.abs_path}")
    return true
  end

end


# ----------------------------------------------------------------------------
# 制御ファイル処理
# ----------------------------------------------------------------------------

def read_control(dir)
  c = nil
  open("#{dir}/control", "r") do |s|
    c = s.read(1)
  end
  return c
end

def write_control(dir, c)
  open("#{dir}/control", "w") do |s|
    s.putc(c)
  end
end

# ----------------------------------------------------------------------------
# (main) : メインプログラム
# ----------------------------------------------------------------------------

# デバッグモード
debug = false

# 設定ファイルを求める
pwd = ARGV.shift
cf = Suzaku::Config.new("../" + Local_conf_file)

# 設定ファイルによる初期設定
host          = cf.parm["host"]
userid        = cf.parm["userid"]
password      = cf.parm["password"]
database      = cf.parm["database"]
interval      = cf.parm["interval"]
time_limit    = cf.parm["time_limit"]
start_level   = cf.parm["start_level"]
max_level     = cf.parm["max_level"]
max_continue  = cf.parm["max_continue"]
tmp_dir       = cf.parm["tmp_dir"]
log_dir       = cf.parm["log_dir"]
log_out       = cf.parm["log_out"]
limit_in_same_site = cf.parm["limit_in_same_site"]
message_out   = cf.parm["message_out"]
force         = cf.parm["force"]
auto_delete   = cf.parm["auto_delete"]

# ログファイルのオープン
log = Log.new(debug)
start_time = Time.now
date_str = start_time.strftime("%Y%m%d-%H%M%S")
if log_out
  log.open("#{log_dir}/#{Logname}-#{date_str}", "a")
else
  log.open($stdout)
end

# パスワードチェック
if pwd != password
  log.e_msg("main", 9, "password unmach : #{pwd}")
  exit 1
end

# 実行時オプションによる設定
id = top_id = nil
while f = ARGV.shift
  # デバッグモードに設定する
  if f == '-d'
    debug = true
    message_out = true
  # メッセージ出力モードに設定する
  elsif f == '-m'
    message_out = true
  # ログを標準出力に切り替える
  elsif f == '-o'
    log_out = false
  # 強制的に parse する
  elsif f == '-f'
    force = true
  # 巡回をサイト内に制限する
  elsif f == '-l'
    limit_in_same_site = true
  # 巡回をサイト内に制限しない
  elsif f == '-a'
    limit_in_same_site = false
  # 前回のチェック時間を考慮しない
  elsif f == '-i'
    interval = 0  
  # 巡回を開始するレベルを指定する
  elsif /-s(\d+)$/ =~ f
    start_level = $1.to_i 
  # 巡回を終了するレベルを指定する
  elsif /-e(\d+)$/ =~ f
    max_level = $1.to_i 
  # 指定された url-id のページだけを解析する
  elsif /-u(\d+)$/ =~ f
    id = $1.to_i
    force = true 
  # 指定された url-id がトップレベルのページだけを解析する
  elsif /-t(\d+)$/ =~ f
    top_id = $1.to_i
    force = true
  # それ以外
  else
    log.e_msg("main", 1, "illegal opiton #{f}")
    exit 1
  end
end

# 設定値のチェック
if host           ; else; log.e_msg("main", 8, "host not set");         exit 1; end
if userid         ; else; log.e_msg("main", 8, "userid not set");       exit 1; end
if password       ; else; log.e_msg("main", 8, "password not set");     exit 1; end
if database       ; else; log.e_msg("main", 8, "database not set");     exit 1; end
if interval       ; else; log.e_msg("main", 8, "interval not set");     exit 1; end
if time_limit     ; else; log.e_msg("main", 8, "time_limit not set");   exit 1; end
if start_level    ; else; log.e_msg("main", 8, "start_level not set");  exit 1; end
if max_level      ; else; log.e_msg("main", 8, "max_level not set");    exit 1; end
if max_continue   ; else; log.e_msg("main", 8, "max_continue not set"); exit 1; end
if tmp_dir        ; else; log.e_msg("main", 8, "tmp_dir not set");      exit 1; end
if log_dir        ; else; log.e_msg("main", 8, "log_dir not set");      exit 1; end
if log_out        ; else; log.e_msg("main", 8, "log_out not set");      exit 1; end

# 処理開始メッセージ
log.n_msg("main start.")
time_over_f = false
stop_f = false
c1 = c2 = c3 = c4 = c5 = 0
f1 = f2 = nil

# データベースのオープン
db = WebDB.new
db.open(host, userid, password, database)

http = Http.new(Agentname, tmp_dir)
rb = Robot.new(log, Agentname, tmp_dir)
fconv = FileConvert.new
parser = Parser.new(log)

# 制御ファイル設定
ctl = Control.new(tmp_dir)
ctl.start

# 所定のツリーレベルまで実行
(start_level..max_level).each do |n|

  # 処理時間制限のチェック
  log.debug("main: 1")
  if time_over_f
    break
  end

  # 停止指示のチェック
  log.debug("main: 2")
  if stop_f
    break
  end

  # 処理開始メッセージ
  log.n_msg("tree_level #{n} start.")

  if (id == nil) && (top_id == nil)
    # 同一サイトへのアクセス集中を避けるため、sid を設定する
    res = db.select_url_1(n)
    ctr = 0
    u = Url.new
    h0 = ""
    sid = rand(9999999)
    res.each do |url_id, url|
      u.parse(url)
      h1 = u.host
      db.update_url_sid(url_id, sid)
      if h0 != h1
        h0 = h1
        next
      else
        ctr += 1
        # ホスト名が max_continue 連続したら、sid を変更する
        if ctr >= max_continue
          sid = rand(9999999)
          ctr = 0
        end
        h0 = h1
      end
    end
  end

  # 各ツリーレベルのURLを巡回(order sid, url_id)
  log.debug("main: 3")
  res = db.select_url_2(n)
  res.each do |sid, url_id, url, tree_level, top_url_id, saved_last_modified_str, saved_last_parsed_str, response|

    begin
      # 処理時間制限のチェック
      log.debug("main: 4")
      if (Time.now - start_time) > time_limit
        time_over_f = true
        log.n_msg("time over.")
        break
      end

      # 停止指示のチェック
      log.debug("main: 5")
      if ctl.stop?
        stop_f = true
        log.n_msg("stop.")
        break
      end

      # id に指定された url_id のみを処理する
      log.debug("main: 6")
      if id
        if id != url_id.to_i
          next
        end
      end
      
      # top_id に指定された url_id がトップレベルの url のみを処理する
      log.debug("main: 7")
      if top_id
        if top_id != top_url_id.to_i
          next
        end
      end

      # 最後に解析処理を行ってから一定時間経っていない場合は処理しない
      log.debug("main: 8")
      saved_last_parsed = db.from_sql_datetime(saved_last_parsed_str)
      if saved_last_parsed
        if ((Time.now - saved_last_parsed) < interval) && (force == false)
          if message_out
            log.n_msg("#{url} [#{url_id}] skip. too short interval.")
          end
          c1 += 1
          next
        end
      end

      # 処理開始

      # アクセス方式のチェック
      access_mode = db.select_information_access(top_url_id)

      # robots.txt のチェック
      log.debug("main: 9")
      if !(rb.check(url, access_mode))
        log.n_msg("#{url} [#{url_id}] robots.txt check - false.")
        c2 += 1
        next
      end

      # url で指定されたファイルを GET
      log.debug("main: 10")
      http.set_url(url, access_mode)
      http.get
      
      while http.code == '301' || http.code == '302' || http.code == '303' || http.code == '304' 
        log.n_msg("#{url} [#{url_id}] moverd. -> #{http.location}")
        http.set_url(http.location)
        http.get
      end

      # 登録データの削除
      log.debug("main: 11")
      if auto_delete
        # keyword
        if http.code == '200' || http.code == '403' || http.code == '404'
          db.delete_keywords(url_id)
        end
        # url
        if (http.code == '403' || http.code == '404') && tree_level.to_i >= 2
          db.delete_url(url_id)
        end
      end
      
      # OK 以外であればエラー
      log.debug("main: http.code #{http.code}")
      if http.code != '200'
        raise  "rc:#{http.code}"
      end

      # ファイルの更新日のチェック
      log.debug("main: 12")
      saved_last_modified = db.from_sql_datetime(saved_last_modified_str)
      if http.last_modified && saved_last_modified
        if (http.last_modified <= saved_last_modified) && (force == false)
          # 更新されていないファイルは処理しない
          if message_out
            log.n_msg("#{url} [#{url_id}] not modified.")
          end
          db.update_last_checked(url_id, Time.now, http.code)
          c3 += 1
          next
        end
      end

      # ファイルの更新日をセット
      log.debug("main: 13")
      if http.last_modified
        current_last_modified = http.last_modified
      elsif saved_last_modified
        current_last_modified = saved_last_modified
      else
        current_last_modified = nil
      end

      f1 = http.dir + http.local_file
#     f2 = http.dir + http.local_file + ".euc"
      f2 = http.dir + http.local_file + ".utf8"
      log.debug("main: f1 = #{f1}")
      log.debug("main: f2 = #{f2}")

      # ローカルファイルの文字コードをUTF8に変換する
#     fconv.to_euc(f1, f2)
      fconv.to_utf8(f1, f2)

      # ローカルファイルをオープンする
      fh = File.open(f2)

      # パーサのセットアップ
      parser.setup(db, fh, url_id, url, n, top_url_id, limit_in_same_site)
    
      # ファイルの解析を開始
      log.debug("main: 14")
      eofsw = parser.token()
      while eofsw do
        log.debug("main: 15")
        eofsw = parser.parse()
      end

      # ローカルファイルをクローズする
      log.debug("main: 16")
      fh.close

      # url にファイルの更新日をセット
      db.update_last_parsed(url_id, current_last_modified, Time.now, http.code)
      
      # 解析の終了処理
      log.debug("main: 17")
      parser.finish
      if message_out
        log.n_msg("#{url} [#{url_id}] parsed.")
      end
      c4 += 1
      
      # ログをフラッシュ
      log.debug("main: 18")
      log.flush

    rescue
      # エラーメッセージを出力
      log.e_msg("main", 2, "#{url} [#{url_id}] #{$@}:#{$!}")
      # url にレスポンスコードをセット
      if http.code
        rc = http.code
      else
        rc = '999'
      end
      db.update_last_checked(url_id, Time.now, rc)
      c5 += 1
      
    ensure
      # ローカルファイル削除
      log.debug("url:#{url}")
      log.debug("http.dir:#{http.dir}")
      log.debug("http.local_file:#{http.local_file}")
      if http.dir && http.local_file && File.exist?(http.dir + http.local_file)
        File.unlink(http.dir + http.local_file)
      end
      if f2 && File.exist?(f2)
        File.unlink(f2)
      end

    end
    log.flush
  end
  log.flush
end

# データベースのクローズ
db.close

# 処理終了メッセージ
log.n_msg("main end. --- total:#{c1 + c2 + c3 + c4 + c5} skip:#{c1} pass_by_robots.txt:#{c2} not_modified:#{c3} parse_normal:#{c4} parse_error:#{c5}")

#ログファイルのクローズ
if log_out
  log.close
end

# 処理終了
exit
