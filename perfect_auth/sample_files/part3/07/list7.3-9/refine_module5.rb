module RefineModule
  refine String do
    def hello
      puts "#{self} hello"
    end
  end
end

using RefineModule
["joker1007", "takkanm"].each(&:hello)
