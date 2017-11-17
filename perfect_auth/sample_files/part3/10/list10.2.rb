# coding: utf-8

class ParentClass
  def super_public_method; end

  private
  def super_private_method; end

  protected
  def super_protected_method; end
end

class ChildClass < ParentClass
  def public_method; end

  private
  def private_method; end

  protected
  def protected_method; end
end

child = ChildClass.new
# オブジェクトに特異メソッドを定義
def child.singleton_method; end
