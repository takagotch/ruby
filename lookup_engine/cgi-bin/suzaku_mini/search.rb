# ----------------------------------------------------------------------------
# search : 文字列検索プログラム
# ----------------------------------------------------------------------------
#
# INPUT:
#
#    db     : データベース
#    and_str: AND検索を行うキーワード
#    or_str : OR 検索を行うキーワード
#    not_str: NOT検索を行うキーワード
#    url    : サイト内検索を行う場合のURL
#    order  : 1:スコア順 2:日付順(新しい順)
#    pos, n : 検索結果のうちpos番目からn個を返す     
#
# OUTPUT:
#
#    res    : 検索結果(Title,URL,Contents,Score,Last-Update)の配列
#    time   : 検索所要時間(秒)
#
# PROCESS:
#
#    1. キーワードをChasenで分割する(分割された語はAND検索を行う)
#    2. AND検索を行う
#    3. OR 検索を行う
#    4. NOT検索を行う
#    5. サイト内検索を行う
#    6. 検索結果を返す
#
# SCORE:
#
#    tf*idf法を用いる
#    (どの文書にも多く含まれる語はスコアを低く、珍しい語はスコアを高くする)
#
#    d       : 文書
#    E       : 検索式
#    k       : キーワード
#    W       : スコア
#    N       : 全文書数
#    n       : キーワードを含む文書数
#
#    w(d,k) = tf(d,k) * idf(k)
#    w(d,A and B) = min(w(d,A), w(d,B))
#    w(d,A or B) = max(w(d,A), w(d,B))
#    w(d,A not B) = w(d,A)
#
#    w(d,E)  : 文書dの検索式Eにおけるスコア
#    tf(d,k) : 文書dにおけるキーワードkの出現頻度(重み付けあり)
#    idf(k) = log(N/n)
#

# システムライブラリ
require 'mysql'
require 'parsedate'
require 'chasen'

# Suzaku 共通コンスタント／ライブラリ
require 'lib/constant.rb'
require 'lib/suzaku_lib.rb'
include Suzaku

# ----------------------------------------------------------------------------
# WebDB : データベース処理クラス
# ----------------------------------------------------------------------------

class WebDB
  attr_reader :dbh

  # 初期化
  def initialize
    # データベースハンドル
    @dbh = nil
    # 一時テーブル名のサフィックス
    @table_name_id = 1
  end
    
  # データベースのオープン
  def open()
    # 設定ファイルの読み込み
    cf = Config.new(Local_conf_file)
    # MySQLとのコネクション確立
    host = cf.parm["host"]
    userid = cf.parm["userid"]
    password = cf.parm["password"]
    database = cf.parm["database"]
    @dbh = Mysql::new(host, userid, password, database)
    @dbh.query("SET NAMES utf8")
  end

  # データベースのクローズ
  def close()
    @dbh.close
  end
  
  # 一時テーブル名の取得
  def get_temp_keyword_table_name()
    name = "temp_keyword_table#{@table_name_id}"
    @table_name_id += 1
    return name
  end

  # 一時テーブルの作成
  def create_temp_keyword_table(name)
    @dbh.query("CREATE TEMPORARY TABLE #{name} (\
      url_id INT UNIQUE NOT NULL DEFAULT '0',\
      score FLOAT,\
      PRIMARY KEY (url_id))")
  end

  # keywordテーブルをキーワード検索する
  def select_keyword_table(t1, w1, idfk)
    debug("\nSEARCH t1:#{t1} w1:#{w1} idfk:#{idfk}")
    @dbh.query("INSERT INTO #{t1} SELECT url_id, score*#{idfk} FROM keyword WHERE keyword = '#{Mysql::quote w1}'")
  end

  # AND処理する
  def and_temp_tables(t3, t1, t2)
    debug("\nAND t3:#{t3} t1:#{t1} t2:#{t2}")
    @dbh.query("INSERT INTO #{t3} SELECT t1.url_id, least(t1.score, t2.score) FROM #{t1} t1, #{t2} t2 WHERE t1.url_id = t2.url_id")
  end
  
  # OR処理する
  def or_temp_tables(t3, t1, t2)
    debug("\nOR t3:#{t3} t1:#{t1} t2:#{t2}")
    # t1, t2 で共通するurl_idのうち、スコアの大きい方をinsertする
    @dbh.query("INSERT INTO #{t3} SELECT t1.url_id, t1.score FROM #{t1} t1, #{t2} t2 WHERE t1.url_id = t2.url_id AND t1.score > t2.score")
    @dbh.query("INSERT INTO #{t3} SELECT t2.url_id, t2.score FROM #{t1} t1, #{t2} t2 WHERE t1.url_id = t2.url_id AND t1.score <= t2.score")
    # 重複しないurl_idをinsertする
    @dbh.query("INSERT IGNORE INTO #{t3} SELECT t1.url_id, t1.score FROM #{t1} t1")
    @dbh.query("INSERT IGNORE INTO #{t3} SELECT t2.url_id, t2.score FROM #{t2} t2")
  end
  
  # NOT処理する
  def not_temp_tables(t1, t2)
    debug("\nNOT t1:#{t1} t2:#{t2}")
    res = @dbh.query("SELECT url_id FROM #{t2}")
    res.each do |id|
      @dbh.query("DELETE FROM #{t1} WHERE url_id = #{id}")
    end
  end
  
  # サイト名でマッチング処理する
  def select_temp_tables_like_url(t2, t1, url)
    debug("\nURL t2:#{t2} t1:#{t1} url:#{url}")
    @dbh.query("INSERT INTO #{t2} SELECT t1.url_id, t1.score FROM #{t1} t1, url WHERE t1.url_id = url.url_id AND url.url LIKE '#{Mysql::quote url}%'")
  end
  
  # URLの総数を求める
  def select_count_url
    res = @dbh.query("SELECT COUNT(*) FROM url")
    dn = nil
    res.each do |n_str,|
      dn = n_str.to_i
    end
    return dn
  end

  # キーワードが含まれる文書数を求める
  def select_count_word(w1)
    res = @dbh.query("SELECT COUNT(*) FROM keyword WHERE keyword = '#{Mysql::quote w1}'")
    kn = nil
    res.each do |n_str,|
      kn = n_str.to_i
    end
    return kn
  end

  # URLを求める
  def select_all_url_id(t1)
    res = @dbh.query("SELECT url_id FROM #{t1}")
    return res
  end

  # キーワードのスコアを求める
  def select_score(url_id, w1)
    debug("url_id:#{url_id} w1:#{w1}")
    res = @dbh.query("SELECT score FROM keyword WHERE url_id = #{url_id} AND keyword = '#{Mysql::quote w1}'")
    score = nil
    res.each do |score_str,|
      score = score_str.to_i
    end
    debug("score:#{score}")
    if score
      return score
    else
      return 0
    end
  end

  # 結果のURLを求める
  def select_result(t2, order, pos, n)
    if order == Order_by_score
      res = @dbh.query("SELECT t1.url_id, t1.url, t2.score, t1.last_modified, t1.title, t1.abstract FROM url t1, #{t2} t2 WHERE t1.url_id = t2.url_id ORDER BY t2.score DESC LIMIT #{pos},#{n}")
      return res
    elsif order == Order_by_date
      res = @dbh.query("SELECT t1.url_id, t1.url, t2.score, t1.last_modified, t1.title, t1.abstract FROM url t1, #{t2} t2 WHERE t1.url_id = t2.url_id ORDER BY t1.last_modified DESC LIMIT #{pos},#{n}")
      return res
    else
      raise "WebDB.select_result order param error."
    end
  end

  # URLの総数を求める
  def select_count_result(t2)
    res = @dbh.query("SELECT COUNT(*) FROM #{t2}")
    dn = nil
    res.each do |n_str,|
      dn = n_str.to_i
    end
    return dn
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

  # ログを出力する
  def log(start_time, process_time, keywords)
    sstr = to_sql_datetime(start_time)
    @dbh.query("INSERT INTO searchlog SET log_id = NULL, start_time = '#{sstr}', process_time = '#{process_time}', keywords = '#{Mysql::quote keywords}'")
  end

  # デバッグ用
  def debug(str)
    # puts str
  end

end

# ----------------------------------------------------------------------------
# SearchEngine : 検索処理クラス
# ----------------------------------------------------------------------------

class SearchEngine
  attr_reader :db

  # 初期化
  def initialize
    @db = WebDB.new
    @keywords = Array.new
    @debeg = false

  end

  # データベースをオープン
  def db_open
    @db.open
  end

  # データベースをクローズ
  def db_close
    @db.close
  end

  # キーワードによる検索
  def search(and_str, or_str, not_str, url_str, order, pos, n)

    # セットアップ
    setup(and_str, or_str, not_str, url_str)

    # 文書の総数を求める
    @dn = @db.select_count_url
    debug("N: #{@dn}")
    
    # idf(k)を求める
    idf_k
    
    # キーワード検索を行う
    t1 = nil
    eofsw = get_first_keyword
    while eofsw
      t1 = parse(t1)
      eofsw = get_next_keyword
    end

    # URLによるサイト内制限処理を行う
    debug("SITE")
    
    @url_words.each do |url|
      t1 = site_search(t1, url)
      dump(url, t1)
    end
  
    # 検索結果のURLを求める
    dn = @db.select_count_result(t1)
    res = @db.select_result(t1, order, pos - 1, n)

    # 検索に使用したキーワード
    sstr = ""
    @keywords.each do |w|
      sstr << w.gsub(/\s+/, '')
    end

    return res, dn, sstr
  end
  
  # 茶筌によるキーワードの分割
  def split_word(word)
    words = Array.new
    words.push(' ( ')
    first_f = true
    # strを茶筌で解析する
    Chasen.getopt("-F", "%m\t:%h\n", "-j", "-i", "w")
    Chasen.sparse(word.untaint).each do |line|
      if /^(\S+)\s+:(\d+)$/ =~ line
        if first_f
          first_f = false
        else
          words.push(' & ')
        end
        words.push($1)
      end
    end
    words.push(' ) ')
    return words
  end

  # 検索処理の前準備をする
  def setup(and_str, or_str, not_str, url_str)
 
    # 全角'  'を半角' 'に変換する
    @and_str = and_str.gsub(/　/, ' ')
    @or_str = or_str.gsub(/　/, ' ')
    @not_str = not_str.gsub(/　/, ' ')

    # 入力されたキーワードを分析して配列に格納する
    and_first_f = true
    # and_str
    and_words = @and_str.scan(/\S+/)
    and_words.each do |w1|
      words = split_word(w1)
      if and_first_f
        @keywords.push(' ( ')
        and_first_f = false
      else
        @keywords.push(' & ')
      end
      words.each do |w2|
        @keywords.push(w2)
      end
    end
    if !and_first_f
      @keywords.push(' ) ')
    end
    # or_str
    or_first_f = true
    or_words = @or_str.scan(/\S+/)
    or_words.each do |w1|
      words = split_word(w1)
      if or_first_f
        if !and_first_f
          @keywords.push(' & ')
        end
        or_first_f = false
        @keywords.push(' ( ')
      else
        @keywords.push(' + ')
      end
        words.each do |w2|
          @keywords.push(w2)
        end
    end
    if !or_first_f
      @keywords.push(' ) ')
    end      
    # not_str
    not_words = @not_str.scan(/\S+/)
    not_words.each do |w1|
      words = split_word(w1)
      @keywords.push(' - ')
      words.each do |w2|
        @keywords.push(w2)
      end
    end

    # and_str, or_strとも指定がない場合にはエラー
    if @keywords.empty? || @keywords[0] == ' - '
      raise "SearchEngine.search: and_str & or_str empty."
    end

    debug("@keywords: #{@keywords}")
    
    # 指定されたURLを配列に格納する
    @url_words = url_str.scan(/\S+/)
  end

  # 最初のキーワードを求める
  def get_first_keyword
    @index = 0
    @word = @keywords[@index]
    # debug("@word: #{@word}")
    @index += 1
    if @word
      return true
    else
      return false
    end
  end

  # 次のキーワードを求める
  def get_next_keyword
    @word = @keywords[@index]
    debug("@word: #{@word}")
    @index += 1
    if @word
      return true
    else
      return false
    end
  end  

  # 検索処理
  def parse(t1)
    # '(' の処理
    if @word == ' ( '
      debug("#{@word}")
      eofsw = get_next_keyword
      while eofsw
        if @word == ' ) '
          return t1
        else
          t1 = parse(t1)
          if !t1
            raise "SearchEngine.parse: parse error(1)."
          end
          eofsw = get_next_keyword
        end
      end
    # ')' の処理
    elsif @word == ' ) '
      debug("#{@word}")
      return t1
    # AND 処理
    elsif @word == ' & '
      debug("#{@word}")
      eofsw = get_next_keyword
      if eofsw  
        t2 = parse(nil)
        if !t2
          raise "SearchEngine.parse: parse error(2)."
        end
        t1 = and_search(t1, t2)
        if t1
          return t1
        else
          raise "SearchEngine.parse: and search error."
        end   
      end
    # OR 処理
    elsif @word == ' + '
      debug("#{@word}")
      eofsw = get_next_keyword
      if eofsw  
        t2 = parse(nil)
        if !t2
          raise "SearchEngine.parse: parse error(3)."
        end
        t1 = or_search(t1, t2)
        if t1
          return t1
        else
          raise "SearchEngine.parse: or search error."
        end
      end
    # NOT 処理
    elsif @word == ' - '
      debug("#{@word}")
      eofsw = get_next_keyword
      if eofsw  
        t2 = parse(nil)
        if !t2
          raise "SearchEngine.parse: parse error(4)."
        end 
        t1 = not_search(t1, t2)
        if t1
          return t1
        else
          raise "SearchEngine.parse: not search error."
        end
      end
    # キーワードの検索
    else
      t1 = word_search(@word)
      if t1
        return t1
      else
        raise "SearchEngine.parse: word search error."
      end
    end
    # その他
    raise "SearchEngine.parse: other error."
  end

  # キーワード検索
  def word_search(w1)
    # 一時テーブルを作成する
    t1 = @db.get_temp_keyword_table_name
    @db.create_temp_keyword_table(t1)
    # キーワード検索する
    @db.select_keyword_table(t1, w1, @idfs[@word])
    dump(w1, t1)
    # 結果のテーブル名を返す
    return t1
  end

  # AND処理
  def and_search(t1, t2)
    # 一時テーブルを作成する
    t3 = @db.get_temp_keyword_table_name
    @db.create_temp_keyword_table(t3)
    # AND処理する
    @db.and_temp_tables(t3, t1, t2)
    dump("AND", t3)
    return t3
  end

  # OR処理
  def or_search(t1, t2)
    # 一時テーブルを作成する
    t3 = @db.get_temp_keyword_table_name
    @db.create_temp_keyword_table(t3)
    # OR処理する
    @db.or_temp_tables(t3, t1, t2)
    dump("OR", t3)
    return t3
  end

  # NOT処理
  def not_search(t1, t2)
    @db.not_temp_tables(t1, t2)
    dump("NOT", t1)
    return t1
  end

  # URLのマッチング処理
  def site_search(t1, url)
    # 一時テーブルを作成する
    t2 = @db.get_temp_keyword_table_name
    @db.create_temp_keyword_table(t2)
    # 指定された文字列とURLのマッチング処理をする
    @db.select_temp_tables_like_url(t2, t1, url)
    return t2
  end

  # idf(k)を求める
  def idf_k
    @idfs = Hash.new
    eofsw = get_first_keyword
    while eofsw
      # 制御文字はスキップする
      if /^\s\S\s$/ =~ @word
        eofsw = get_next_keyword
      else
        kn = @db.select_count_word(@word)
        if kn != 0
          idf = Math.log(@dn.to_f / kn.to_f)
        else
          idf = 0.0
        end
        @idfs[@word] = idf
        debug("idf[#{@word}]: #{idf} = log(#{@dn}/#{kn})")
        eofsw = get_next_keyword
      end
    end
    return true
  end

  # ログ出力
  def log(start_time, process_time, keywords)
    @db.log(start_time, process_time, keywords)
  end

  # デバッグ用
  def dump(s, t1)
    if !@debug
      return
    end
    
    if !t1
      raise "SearchEngine.dump: table name is nil."
    end
    
    print s, ": "
    res = @db.dbh.query("SELECT url_id, score FROM #{t1}")
    res.each do |url_id, score|
      print "#{url_id}[#{score}] "
    end
    print "\n"
  end
  
  def debug(str)
    # puts str
  end

end
