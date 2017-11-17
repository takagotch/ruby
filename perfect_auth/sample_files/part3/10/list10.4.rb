# coding: utf-8

class HasPrivateMethod
  private
  def private_method
    'private_method'
  end
end

has_private_method = HasPrivateMethod.new

has_private_method.respond_to? :private_method #=> false
has_private_method.respond_to? :private_method, true #=> true
# falseを指定すると引数を指定していない時と同じ動作をする
has_private_method.respond_to? :private_method, false #=> false
