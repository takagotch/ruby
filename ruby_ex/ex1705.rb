# -*- coding: utf-8 -*-
# 配列にデータを作成
indians = [ "One little, two little, three little Indians\n",
            "Four little, five little, six little Indians\n",
            "Seven little, eight little, nine little Indians\n",
            "Ten little Indian boys.\n" ]

# "sample5.txt" を書き込みモードで新規に作成
file = File.open("sample5.txt", "w:UTF-8")
indians.each {|indian|
  file.print indian
}

# ファイルを閉じる
file.close

# "sample6.txt" を読み込みモードでオープンする
file =  open("sample5.txt", "r:UTF-8")

# ファイルからデータをすべて読み込み、それを表示する
print file.read

# ファイルを閉じる
file.close
