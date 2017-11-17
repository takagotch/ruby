require 'fiber'

f1 = Fiber.new {
  puts 'from f1'
}

f2 = Fiber.new {
  f1.transfer
  puts 'from f2' # 評価されない
}

f2.resume # => "from f1"
puts 'end'
