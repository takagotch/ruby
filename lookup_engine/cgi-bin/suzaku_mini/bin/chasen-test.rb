require 'chasen'
Chasen.getopt("-F", "%m\t:%h\n", "-j", "-i", "w")
puts Chasen.sparse('今年は2010年です。')
