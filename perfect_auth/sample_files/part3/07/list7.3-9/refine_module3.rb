module RefineModule
  refine String.singleton_class do
    def hello
      puts "#{self} hello class"
    end
  end
end

using RefineModule
String.hello
