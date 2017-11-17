require 'fiber'

p fr = Fiber.new { Fiber.current } # => #<Fiber:0x007fedd9880af8>
p fr_current = fr.resume # => #<Fiber:0x007fedd9880af8>

# frのファイバとfrが返すFiber.currentは同じなのでtrueが返る
p fr == fr_current # => true

# このコンテキストのFiber.currentとfr_currentは違うのでfalseが返る
p Fiber.current == fr_current # => false
