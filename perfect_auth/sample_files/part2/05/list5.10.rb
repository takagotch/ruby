fiber = Fiber.new {
  puts 'Hello, Fiber'

  Fiber.yield

  puts 'Hello (again)'
}

fiber.resume # "Hello, Fiber" と表示

fiber.resume # "Hello (again)" と表示

fiber.resume # FiberError: dead fiber called
