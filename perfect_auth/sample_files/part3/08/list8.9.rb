# coding: utf-8

# Procオブジェクト内でのbreakは常にエラー
Proc.new { break 1 ; puts :unreachable }.call #=> LocalJumpError: break from proc-closure

def proc_break
  Proc.new { break 1 ; puts :unreachable }.call
end

proc_break #=> LocalJumpError: break from proc-closure

# lambdaのbreakはreturnと同じ
lambda { break 1; puts :unreachable }.call #=> 1

def lambda_break
  lambda { break 1; puts :unreachable }.call
  :reachable
end

lambda_break #=> :reachable
