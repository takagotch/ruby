# -*- coding: utf-8 -*-
# "sample1.txt" を読み込みモードでオープンする
file =  open("sample1.txt", "r:UTF-8")

# ファイルの行を1行ずつ取り出して、lineに読み込む
file.each {|line|
    # lineを表示する
    print line
}

# ファイルを閉じる
file.close
