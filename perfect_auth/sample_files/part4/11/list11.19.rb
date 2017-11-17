require 'uri'
require 'net/http'

uri  = URI.parse('http://www.ruby-lang.org/ja/')
http = Net::HTTP.new(uri.host, uri.port)

http.start # HTTPセッションを開始する
p http.active? # HTTPセッションが開始されていれば真
http.finish # HTTPセッションを終了する

http.start # HTTPセッションを再び開始する（すでに開始されていればIOError）

# 接続時のタイムアウト（秒）
http.open_timeout = 30
p http.open_timeout # => 30

# 読み込みのタイムアウト（ブロックできる最大秒数）
http.read_timeout = 60
p http.read_timeout # => 60
