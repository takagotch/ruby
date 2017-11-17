# == Sample Module
module SampleModule
  # == NoDocumentSample Class
  class NoDocumentSample # :nodoc:
    def method_name
      #do something
    end
  end

  # == Document Class
  class DocumentSample
    def method_name
      #do something
    end
  end
end

# == NoDocumentAll Module
module NoDocumentAll # :nodoc: all
  # == ここに書いてあるものはドキュメントとして生成されない
  class ClassName
  end
end
