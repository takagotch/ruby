p 'hello'.class # String と表示
p String.ancestors # [String, Comparable, Object, Kernel, BasicObject] と表示

p 10.class # Fixnum と表示
p Fixnum.ancestors # [Fixnum, Integer, Numeric, Comparable, Object, Kernel, BasicObject] と表示

p true.class # TrueClass と表示
p TrueClass.ancestors # [TrueClass, Object, Kernel, BasicObject] と表示

p nil.class # NilClass と表示
p NilClass.ancestors # [NilClass, Object, Kernel, BasicObject] と表示
