# システムライブラリ
require 'socket'
require 'net/http'
require 'net/smtp'
require 'base64'
require 'kconv'

# module Suzaku start
module Suzaku

# ---------------------------------------------------
# Log : ログクラス
# ---------------------------------------------------

class Log

  # 初期化
  def initialize(debug = false)
    @debug = debug
  end
  
  # debug フラグセット
  def set_debug(f)
    @debug = f
  end
  
  # open
  def open(file = $stdout, mode = "w")
    if file == $stdout
      @msgout = $stdout
    else
      @msgout = File.open(file, mode)
    end
  end
  
  # close
  def close
    if @msgout != $stdout
      @msgout.close
    end
  end
  
  # flush
  def flush
    if @msgout != $stdout
      @msgout.flush
    end
  end
  
  # 正常メッセージ
  def n_msg(msg)
    t = Time.now
    str = t.strftime("%Y-%m-%d %H:%M:%S")
    @msgout.print str
    @msgout.print ": #{msg}\n" 
  end

  # 警告メッセージ
  def w_msg(fn, code, msg)
    t = Time.now
    str = t.strftime("%Y-%m-%d %H:%M:%S")
    @msgout.print str
    @msgout.print ": Warning #{fn}(#{code}) #{msg}\n" 
  end

# エラーメッセージ
  def e_msg(fn, code, msg)
    t = Time.now
    str = t.strftime("%Y-%m-%d %H:%M:%S")
    @msgout.print str
    @msgout.print ": Error #{fn}(#{code}) #{msg}\n" 
  end

  # デバッグメッセージ
  def debug(msg)
    if @debug
      @msgout.puts msg
    end
  end
  
end

# ----------------------------------------------------------------------------
# Url : URL解析クラス
# ----------------------------------------------------------------------------

# URLを host, port, abs_path, query, fragment に分解する
# "http:" "//" host [ ":" port ] [ abs_path ] [ "?" query ] [ "#" fragment ]
#
# http      大文字・小文字を区別しない。
# host      IPアドレスまたはドメインネーム。大文字・小文字を区別しない。
# port      ポート番号。httpの場合、デフォルトは80。
# abs_path  絶対パス。デフォルトは"/"。大文字・小文字を区別する。
# query     クエリ文字列。CGIにパラメータを渡す場合などに用いる。
# fragment  フラグメント。同一ページ内のリンク指定に用いる。
#

class Url
  attr_reader :host, :port, :abs_path, :query, :fragment, :base_dir, :url

  # 初期化
  def initialize(url = nil)
    @host = @port = @abs_path = @query = @fragment = @base_dir = @url = nil
    if url
      parse(url)
    end
  end

  # URLの解析
  def parse(url)
    @host = @port = @abs_path = @query = @fragment = @base_dir = @url = nil
    
    if /^http:\/\/(.+)/i =~ url
      (@host, @port, @abs_path, @query, @fragment), = $1.scan(/^([^\/:]*)(?::(\d+))?(\/[^\?\#]*)?(\?[^\#]+)?(\#.+)?/)
      if @host
        if @abs_path == nil
          @abs_path = "/"
        end
        if @port == nil
          @port = 80
        end
        # @abs_pathの末尾が"/"だったら、ダミーのファイル名を追加する
        if /\/$/ =~ @abs_path
          @base_dir = File.dirname(@abs_path + "dummy.html")
        else
          @base_dir = File.dirname(@abs_path)
        end
      end
    end
    @url = url
  end

  # 絶対パスへの変換
  def convert_to_abs_path(url)
    # 基準となるURLがセットされていない場合
    if !@host
      return nil
    end
    # 絶対パスの場合(変換不要)
    if /^http:\/\//i =~ url
      return url
    else
    # 相対パスの場合
      a_url = "http://" + @host
      if @port != 80
        a_url += ":#{port}"
      end
      a_url += File.expand_path(url, @base_dir)
      return a_url
    end
  end

  # URLの再取得
  def get_url()
    a_url = "http://" + @host
    if @port != 80
      a_url += ":#{port}"
    end
    a_url += @abs_path
    return a_url
  end
end

# ----------------------------------------------------------------------------
# Http : httpクラス
# ----------------------------------------------------------------------------

class Http
  attr_reader :url, :code, :len, :last_modified, :content_type, :dir
  attr_reader :remote_file, :local_file, :location

  # 初期化
  def initialize(agent = nil, dir = ".")
    @url = @code = @len = @last_modified = @content_type = nil
    @remote_file = @local_file = @location = nil
    @url_parsed = Url.new
    @header = Hash.new
    @header['Accept'] = '*/*'
    if agent
      @header['User-Agent'] = agent
    end
    @dir = dir
    # dirの末尾が"/"でなかったら"/"を追加する
    if /\/$/ =~ @dir
    else
      @dir += "/"
    end
    @access = nil
  end

  # URLを設定する
  def set_url(url, ac = 0)
    # アクセスモードを設定する
    set_access_mode(ac)
    # urlを設定する
    @code = @len = @last_modified = @content_type = nil
    @url = url
    @url_parsed.parse(url)
    # リモートファイル名を設定する
    if @url_parsed.query
      @remote_file = @url_parsed.abs_path + @url_parsed.query
    else
      @remote_file = @url_parsed.abs_path
    end
    # ローカルファイル名を設定する
    if /\/$/ =~ @url_parsed.abs_path
      @local_file = "index.html"
    else
      @local_file = File.basename(@url_parsed.abs_path)
    end
  end

  # URLを求める
  def get_url()
    return @url_parsed.get_url
  end

  # アクセスモードを設定する
  def set_access_mode(ac)
    @access = ac
    case @access
    when 0
      if @header.key?('Connection')
        @header.delete('Connection')
      end
    when 1
      @header['Connection'] = 'close'
    else
      raise "accsess:#{@access}"
    end          
  end
  
  # リモートファイルを取得する
  def get()
    lf = nil
    begin
      @http = @code = @content_type = @len = @last_modified = nil
      timeout(80) do
        # 接続開始
        Net::HTTP.version_1_2
        @http = Net::HTTP.new(@url_parsed.host, @url_parsed.port)
        @http.open_timeout = 20
        @http.read_timeout = 60 
        @http.start

        # リモートファイルを取得
        lf = File.open(@dir + @local_file, "w")
        lf.binmode
        response = @http.get(@remote_file, @header) do |s|
          lf.write s
        end

        lf.close
      
        # ヘッダ情報のチェック
        @code = response.code
        # OK 
        if @code == '200'
          @content_type = response['content-type']
          @len = response['content-length'].to_i
          last_str = response['last-modified']
          if last_str
            (year, month, day, hour, min, sec, zone, youbi) = ParseDate.parsedate(last_str)
            @last_modified = Time.mktime(year, month, day, hour, min, sec)
          else
            @last_modified = nil
          end
        end
        # Moved
        if @code == '301' || @code == '302' || @code == '303' || @code == '307'
          @location = response['location']
        end
      
        # 接続終了
        @http.finish
      end

    rescue TimeoutError
      # 例外処理
      if lf
        lf.close
      end
      raise "Net::HTTP.get timeout."

    rescue
      # 例外処理
      if lf
        lf.close
      end
      raise
    end
  end

  # アクセスチェック
  def test()
    for ac in 0..1 do
      set_access_mode(ac)
      begin
        @http = @code = @content_type = @len = @last_modified = nil
        timeout(30) do
          # 接続開始
          Net::HTTP.version_1_2
          @http = Net::HTTP.new(@url_parsed.host, @url_parsed.port)
          @http.open_timeout = 10
          @http.read_timeout = 20
          # puts "test: #{url} ac=#{ac}"
          @http.start
          # GET
          response = @http.get2(@remote_file, @header) do |rf|
          rf.body do |s|
            # puts s
          end
          end
          # 接続終了
          @http.finish
      
          # ヘッダ情報のチェック
          @code = response.code
          # OK 
          if @code == '200'
            return ac
          # Moved
          elsif @code == '301' || @code == '302' || @code == '303' || @code == '307'
            @location = response['location']
            set_url(@location)
            redo
          else
            return -1
          end
        end
      rescue
        # 例外処理
        # puts "ERROR: ac=#{ac} #{$!}"
      end
    end
    return -1
  end
  
end

# ----------------------------------------------------------------------------
# FileConvert : ファイルのコード変換クラス
# ----------------------------------------------------------------------------
#
# Kconv::AUTO    : 0
# Kconv::JIS     : 1
# Kconv::EUC     : 2
# Kconv::SJIS    : 3
# Kconv::BINARY  : 4
# Kconv::UTF8    : ?  <-- Ruby 1.8.2 feature
# Kconv::UNKNOWN : 0

class FileConvert
  attr_reader :from_code, :to_code, :rc
  
  # 初期化
  def initialize
    @rc = 0
  end
  
  # EUC へ変換
  def to_euc(f1, f2)
    convert(f1, f2, Kconv::EUC)
  end
  
  # SJIS へ変換
  def to_sjis(f1, f2)
    convert(f1, f2, Kconv::SJIS)
  end

  # UTF8 へ変換
  def to_utf8(f1, f2)
    convert(f1, f2, Kconv::UTF8)
  end

  # ファイルのコード変換
  def convert(fn1, fn2, code)
    # ファイルをオープンする
    f1 = open(fn1, "r")
    f2 = open(fn2, "w")
    # 1行づつコード変換する
    while line = f1.gets
      if code == Kconv::EUC
        f2.print line.toeuc
      elsif code == Kconv::SJIS
        f2.print line.tosjis
      elsif code == Kconv::UTF8
        f2.print line.toutf8
      else
        rc = 1
        break
      end
    end
    # ファイルをクローズする
    f1.close
    f2.close
  end
  
end

# ----------------------------------------------------------------------------
# Config : 設定ファイルクラス
# ----------------------------------------------------------------------------

# 設定ファイルの書式
# 
#   書式：　キーワード = 値
#   値には、整数、実数、true/false、文字列("...")が使用できる
#   なお、行頭に # があれば、コメント行とみなす

class Config
  attr_reader :parm
  
  def initialize(file = nil)
    @parm = Hash.new
    if file
      read("#{Config_path}/#{file}")
    else
      read(Config_File)
      read("#{Config_path}/#{@parm["config_file_name"]}")
    end
  end

  # 設定ファイル読み込み
  def read(file)
    open(file.untaint) do |f|
      while line = f.gets
      # コメント行または空白行はスキップする
        if /^\s*\#/ =~ line || /^\s*$/ =~ line
          next
        end
        # データを評価する
          (key, data), = line.scan(/^\s*(\w+)\s*=\s*(.+)$/)
        if key && data
          # 整数の場合
          if /\A(-?\d+)\s*\Z/ =~ data
            @parm.store(key, data.to_i)
          # 実数の場合
          elsif /\A(-?\d+\.?\d+)\s*\Z/ =~ data
            @parm.store(key, $1.to_f)
          # true/false の場合
          elsif /\Atrue\s*\Z/ =~ data
            @parm.store(key, true)
          elsif /\Afalse\s*\Z/ =~ data
            @parm.store(key, false)   
          # 文字列の場合
          elsif /\A\"((?:[^\"\\]|\\.)*)\"\s*\Z/ =~ data
            @parm.store(key, $1.gsub(/\\\"/, "\""))
          # フォーマットエラー
          else
            raise "Config format error: #{line}"
          end
        # フォーマットエラー
        else
          raise "Config format error: #{line}"
        end
      end
    end
    return @parm
  end
  private :read
  
end

# ----------------------------------------------------------------------------
# Control : 制御ファイルクラス
# ----------------------------------------------------------------------------

class Control
  
  # 初期化
  def initialize(dir)
    @file = "#{dir}/control"
  end
  
  # read
  def read
    data = nil
    open(@file, "r") do |s|
      data = s.gets
    end
    return data
  end
  private :read

  # write
  def write(n)
    data = nil
    open(@file, "w") do |s|
      s.puts(n)
    end
  end
  private :write
  
  # start
  def start
    write('0')
  end

  # stop
  def stop
    write('1')
  end
  
  # stop?
  def stop?
    s = read
    if /1/ =~ s
      return true
    else
      return false
    end
  end

end

# module Suzaku end 
end
