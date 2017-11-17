require 'stringio'

def read_upcase(io)
  io.read.upcase
end

io       = open('|uname') # Windows環境の場合は ver 等に置き換えてください
stringio = StringIO.new('alice')

p read_upcase(io)       # => "DARWIN\n"
p read_upcase(stringio) # => "ALICE"
