# constant.rb : Suzaku 共通コンスタント

# module Suzaku start
module Suzaku

# 漢字コード
$KCODE="UTF8"

# 設定ファイル
Config_path  = '.'
Local_conf_file  = 'suzaku_conf.rb'

# ログファイル
Logname = "suzaku-robot"

# バックアップファイル
Url_list_file = 'url_data.rb'

# HTTPヘッダー
Http_header = {
  "charset" => "UTF-8",
  "type" => "text/html"
}

# 表示順
Order_by_score = 1
Order_by_date  = 2

# module Suzaku end
end
