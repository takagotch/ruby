# coding: utf-8

class EvalTarget
  CONST_VAL = "EvalTarget::CONST"
  attr_accessor :instance_val
end

CONST_VAL = "CONST"

e1 = EvalTarget.new

# evalのブロック内でCONST_VALを参照してもEvalTarget::CONST_VALが参照されてしまう
e1.instance_eval { @instance_val = CONST_VAL }
e1.instance_val #=> "EvalTarget::CONST"

# CONST_VALをinstance_execの引数で渡すと、このコンテキストのCONST_VALを渡せる
e1.instance_exec(CONST_VAL) {|const_val| @instance_val = const_val }
e1.instance_val #=> "CONST"
