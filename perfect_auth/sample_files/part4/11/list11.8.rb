require 'csv'

data = <<EOS
name,age,gender
alice,14,female
bob,32,male
carol,17,female
EOS

CSV.parse(data, headers: :first_row) do |row|
  # ヘッダ名をキーにしてハッシュのようにアクセスできる
  name = row['name']
  age, gender = row.values_at('age', 'gender')

  puts "#{name} is #{gender} (#{age})" # => alice is female (14) などと表示
end
