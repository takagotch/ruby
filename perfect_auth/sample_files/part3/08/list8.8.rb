# coding: utf-8

# メソッド内でreturnすると、Procオブジェクトのreturnがメソッドのreturnとなる
def proc_return
  Proc.new { return 1; puts :unreachable }.call
  :unreachable # この値は戻り値にならない
end

proc_return #=> 1
# メソッド外でreturnするProcオブジェクトを実行するとエラー
Proc.new { return 1; puts :unreachable }.call #=> LocalJumpError: unexpected return

# 普通のメソッドと同じ挙動になる
lambda { return 1; puts :unreachable }.call #=> 1

def lambda_return
  lambda { return 1; puts :unreachable }.call
  :reachable # lambdaのreturnではメソッドを抜けないので、ここが戻り値になる
end

lambda_return #=> :reachable
