# ==このクラスの説明
#
# Author:: ryopeko
# Version:: 0.0.1
# License:: Ruby License
#
class SampleClass
  # Read, Write両方のaccessorの場合
  attr_accessor :accessor_name

  # Read onlyなaccessorの場合
  attr_reader :read_only_accessor

  #
  # このクラスのVersion
  #
  VERSION = '0.0.1'

  #
  # === initializer
  # メソッドの説明を記述します
  #
  def initialize(name="default_name")
    @accessor_name = name
  end

  #
  # === class_method_name
  # このクラスメソッドについての説明
  # コメントにタグを用いることで<b>強調表現</b>が可能です
  #
  def self.class_method_name
    #do something
  end

  #
  # === instance_method_name
  #
  # リスト表記も可能です
  # - リスト1
  # - リスト2
  # - リスト3
  #
  def instance_method_name(args=[])
    #do something
  end

  private

  #
  # === private_method_name
  #
  def private_method_name
    #do something
  end
end
