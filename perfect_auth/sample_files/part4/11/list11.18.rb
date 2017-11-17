require 'uri'
require 'net/http'

# Web ページを取得して出力する例
uri = URI.parse('http://www.ruby-lang.org/ja/')

# get を使う方法
print Net::HTTP.get(uri)

# get_print を使う方法
Net::HTTP.get_print(uri)
