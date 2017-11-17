for item in %w(foo bar baz)
  Thread.fork do
    sleep 1   # 確実にforループが終わるのを待つ

    puts item # すべてのスレッドで"baz"と表示される
  end
end

(Thread.list - [Thread.current]).each &:join # 子スレッドの終了を待つ
