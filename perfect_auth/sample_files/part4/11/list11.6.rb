require 'csv'

csv = CSV.new(<<EOS)
foo,bar,baz
hoge,piyo,fuga
EOS

csv.each do |row|
  puts row.join('|') # "foo|bar|baz" などと出力される
end
