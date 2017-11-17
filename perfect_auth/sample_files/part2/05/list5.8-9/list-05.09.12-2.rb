require_relative 'list-05.08.12-1'

bucket = Bucket.new

# 何らかの処理をして bucket に結果を書き込む
t1 = Thread.fork {
  25.times do |t |
    sleep rand # 処理にかかる些細な時間
    bucket.append "line: #{t} \n"
  end
}

# bucket に書き込まれた処理結果を一定数ごとに出力する
t2 = Thread.fork {
  5.times do
    bucket.flush
  end
}

[t1, t2].map(&:join)
