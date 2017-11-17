require 'webrick'
require 'webrick/httpproxy'

# プロクシサーバオブジェクトを作る
proxy = WEBrick::HTTPProxyServer.new(
  :BindAddress => '127.0.0.1',
  :Port => 8080,
  # 少しだけプロクシらしい機能を付けてみる
  # アクセスしたサイトのタイトルを標準出力に表示する
  :ProxyContentHandler =>
    ->(req, res) {
      puts res.body.scan(/<title>(.*)< \/title>/im).join rescue nil
    }
)

# SIGINT を捕捉する。Ctrl-Cでシャットダウンさせるため
Signal.trap('INT') do
  # 捕捉した場合、シャットダウンする
  proxy.shutdown
end

# サーバを起動する
proxy.start
