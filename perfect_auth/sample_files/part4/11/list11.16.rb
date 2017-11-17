require 'set'

a = %w(Alice Bob Charlie).to_set
b = %w(Alice Bob).to_set

p a.superset?(b)        # => true (a は b の上位集合)
p b.subset?(a)          # => true (b は a の部分集合)
p a.proper_superset?(b) # => true (a は b の真上位集合)
p b.proper_subset?(a)   # => true (b は a の真上位集合)

p b.superset?(a) # => false (b は a の上位集合ではない)
p a.subset?(b)   # => false (a は b の部分集合ではない)

p a.subset?(a)   # => true (a は a の部分集合)
p a.superset?(a) # => true (a は a の上位集合)

p a.proper_superset?(a) # => false (a は a の真部分集合ではない)
p a.proper_subset?(a)   # => false (a は a の真上位集合ではない)
