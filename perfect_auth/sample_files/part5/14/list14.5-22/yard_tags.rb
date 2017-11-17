# -*- coding: utf-8 -*- #
#
# ==あいさつをするためのクラス #
#

# @author joker1007
# @version 0.1.0
class HelloWorld
  # @abstract 抽象メソッドなのでoverrideしてください
  def abstract_method
    raise NotImplementedError
  end

  # @deprecated このメソッドは非推奨です
  def deprecated_method
    puts "deprecated"
  end

  # @example メソッドの例を示します
  #  example_method("given arg") # => "example given arg"
  def example_method(arg = "arg_sample")
    "example #{arg}"
  end

  # @note ここは大事な説明です
  def note_method(arg = "arg_sample")
    "hello #{arg}"
  end

  # @option option [Symbol] :type あいさつの種類
  # @option option [Boolean] :yobisute(true) 呼び捨てにするかどうか
  def japanese(name = @reader, option = {yobisute: true})
    aisatsu = 'こんにちは'
    keisyou = 'さま'

    aisatsu = 'ごきげんよう' if option[:type] == :ojou
    keisyou = '' if option[:yobisute]

    "#{aisatsu} #{name}#{keisyou}"
  end

  # @overload my_poke(lang, name = @reader)
  #   @param lang [String] 2文字の言語名コードを文字列で表したもの
  # @overload my_poke(lang, name = @reader)
  #   @param lang [Symbol] 2文字の言語名コードをシンボルで表したもの
  # @raise [ArgumentError] 指定した言語コードに対応するメソッドが存在しない場合に発生
  def my_poke(lang, name = @reader)
    case lang.to_sym
    when :ja
      japanese name
    when :en
      english name
    when :es
      spanish name
    else
      raise ArgumentError
    end
  end

  # @param message [String] あいさつの内容
  # @param friends [Array<String>] あいさつする相手の配列
  def hello_friends(message = "hello", friends = [])
    friends.each do |friend|
      puts "Hello #{friend}"
    end
  end

  # @param people [Array<Person>] 人名の配列
  # @return [Person] 友人の名前
  # @return [nil] 友人が見つからなかった場合
  def find_friend(people = [])
    people.find(&:friend?)
  end

  # @see #spanish
  def hola(name = @reader)
    "Hola!! #{name}"
  end

  # @param name [String] 挨拶する人の名前
  # @return [String] スペイン語のあいさつ文
  # @since 0.0.2
  def spanish(name = @reader)
    "Hola!! #{name}"
  end

  # @yield [list] ランダムで実行するメソッドを選ぶためのフィルター
  # @yieldparam list [Array<Symbol>] メソッド名のシンボルが格納された配列
  # @yieldreturn [Symbol] 選択されたメソッド名のしんぼる
  def random_aisatsu(name = @reader, method_list = [], &rule)
    method_list = [:english, :japanese, :spanish] if method_list.empty?
    select_method = yield method_list
    self.send select_method.to_sym, name
  end

  # @!group Callbacks
  #
  def before_filter; end
  def after_filter; end

  # @!endgroup

  # @!macro [new] hello_method
  #  @!method hello_$1
  #   @note $1に挨拶する
  #   @return [void]
  #   @!scope instance
  #   @!visibility public
  def self.define_hello_method(name)
    instance_eval do
      define_method("hello_#{name}") do
        puts "Hello #{name}"
      end
    end
  end

  define_hello_method :joker1007
  define_hello_method :ryopeko
end

class Person
  class << self
    def attribute_reader(sym)
      attr_reader sym
    end
  end

  # @!attribute [r] name
  #   @return [String] 名前を示す文字列
  attribute_reader :name

  # @todo 仮実装なので後でちゃんと実装する
  def friend?
    true
  end
end
