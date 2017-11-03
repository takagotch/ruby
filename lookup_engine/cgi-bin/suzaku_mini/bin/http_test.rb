require 'net/http'
Net::HTTP.version_1_2   # ܂Ȃ
Net::HTTP.start('www.google.co.jp', 80) {|http|
  response = http.get('/index.html')
  puts response.body
}
