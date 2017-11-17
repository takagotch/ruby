class Poke
  # 読者名が格納される
  attr_accessor :reader

  # 著者名が格納される
  attr_reader :authors

  #
  #このクラスのVersion
  #
  VERSION = '0.0.1'

  # @param [String] user_name 読者の名前
  # @return [Poke] Pokeインスタンス
  def initialize(user_name='you')
    @reader = user_name
    @authors = %w(sugamasao takkanm hibariya ryopeko)
  end

  # @param [String] name あいさつする人の名前
  # @return [String] 英語のあいさつ文
  def english(name=@reader)
    "Hello #{name}"
  end
end
