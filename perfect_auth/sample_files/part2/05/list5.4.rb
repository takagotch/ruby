for item in %w(foo bar baz)
  Thread.fork item do |value|
    sleep 1

    puts value # すべてのスレッドで各要素の値が表示される
  end
end

(Thread.list - [Thread.current]).each &:join # 子スレッドの終了を待つ
