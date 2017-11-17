require 'fiber'

fr = Fiber.new { Fiber.yield }

# ファイバが生成れたばかりなのでtrueが返る
p fr.alive? # => true

fr.resume

# Fiber.yieldによって戻ってきたため、まだファイバが完了していないのでtrueが返る
p fr.alive? # => true

fr.resume

# ファイバは完了しているのでfalseが返る
p fr.alive? # => false
