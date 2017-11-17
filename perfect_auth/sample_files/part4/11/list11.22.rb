require 'net/http'

proxy_class = Net::HTTP::Proxy('127.0.0.1', 8080)
http_proxy = proxy_class.new('www.ruby-lang.org')
http_proxy.start do |h |
  # ローカルホストのプロクシ経由で接続
  h.get('/ja/')
end
