# coding: utf-8

class BlankClass
end

BlankClass.constants
  #=> []
BlankClass.const_set :CONST_VAR, 1
  #=> 1
BlankClass.constants
  #=> [:CONST_VAR]
BlankClass.const_get :CONST_VAR
  #=> 1

# 定数を再定義する
BlankClass.const_set :CONST_VAR, 2
  #=> : warning: already initialized constant CONST_VAR
  #=> 2
BlankClass.constants
  #=> [:CONST_VAR]
BlankClass.const_get :CONST_VAR
  #=> 2
