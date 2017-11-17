def hello(names)
  names.each do |name |
    puts "HELLO, #{name.upcase}"
  end
end

rubies = ['MRI', 'jruby', 'rubinius']

hello(rubies)    # 順番に"HELLO, MRI", "HELLO, JRUBY", "HELLO, RUBINIUS"と表示
