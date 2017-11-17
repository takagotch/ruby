require 'socket'

Process.daemon # プロセスをデーモンとして動作させる

TCPServer.open 'localhost', 4423 do |server|
  loop do
    client = server.accept # クライアントからの接続を待ち受ける

    client.puts Time.now   # 現在時刻を返す

    client.close
  end
end
