require 'set'

a = %w(a b c d).to_set
b = %w(c d e f).to_set

# どちらかに含まれる要素の集合（和集合）
p a | b      # => #<Set: {"a", "b", "c", "d", "e", "f"}>
p a.union(b) # => #<Set: {"a", "b", "c", "d", "e", "f"}>

# 両方に含まれる要素のみの集合（積集合）
p a & b             # => #<Set: {"c", "d"}>
p a.intersection(b) # => #<Set: {"c", "d"}>

# 片方だけに含まれている集合（対称差）
p a ^ b # => #<Set: {"e", "f", "a", "b"}>

# aの要素のなかでbには含まれない要素の集合（差集合）
p a - b           # => #<Set: {"a", "b"}>
p a.difference(b) # => #<Set: {"a", "b"}>
