require 'stringio'

def capture_stdout
  captured = StringIO.new
  original = $stdout
  $stdout  = captured # 標準出力を StringIO オブジェクトに

  yield

  # 標準出力をもとに戻して、キャプチャーした文字列を返す
  $stdout = original
  captured.string
end
# puts した内容をキャプチャーする
captured_string = capture_stdout { puts 'Hi, STDOUT!!!' } # "Hi, STDOUT!!! \n"は出力はされない

p captured_string # => "Hi, STDOUT!!! \n"
