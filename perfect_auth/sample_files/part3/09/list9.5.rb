# coding: utf-8

class KeywordArgs
  def normal_method_allow_keyword_args(first_arg, second_arg, third_arg)
    [first_arg, second_arg, third_arg]
  end

  private

  def method_missing(name, *args)
    # メソッド名に_allow_keyword_argsを付けたものが定義されていなれば処理しない
    method_name = name.to_s + '_allow_keyword_args'
    super unless respond_to? method_name

    args_hash = args.first

    # Method.parametersの戻り値を先頭から処理し、
    # _allow_keyword_args無しのメソッド呼び出し時に渡された引数を
    # _allow_keyword_args有りのメソッド呼び出しにマッチするようにする
    new_args = self.method(method_name).parameters.map do |(req, arg_name)|
      args_hash[arg_name]
    end
    __send__ method_name, *new_args
  end
end

KeywordArgs.new.normal_method(third_arg: 1, first_arg: 2, second_arg: 3) # => [2, 3, 1]
