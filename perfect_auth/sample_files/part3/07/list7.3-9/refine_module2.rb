module RefineModule
  refine String do
    def hello
      puts "#{self} hello"
    end
  end
end

class Foo
  using RefineModule
  def hello_foo
    "Foo".hello
  end
end

class Bar
  def hello_bar
    "Bar".hello
  end
end

class Bar
  using RefineModule

  def hello_bar2
    "Bar".hello
  end
end

Foo.new.hello_foo
Bar.new.hello_bar2
Bar.new.hello_bar
