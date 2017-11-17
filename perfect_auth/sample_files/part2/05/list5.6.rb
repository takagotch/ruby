def countup
  File.open 'counter', File::RDWR | File::CREAT do |f|
    last_count = f.read.to_i

    f.rewind
    f.write last_count + 1
  end
end

mutex = Mutex.new

10.times.map {
  Thread.fork {
    mutex.synchronize { countup }
  }
}.map(&:join)

puts File.read('counter').to_i # 正しく10回カウントアップされた値が表示される
