# suzaku_conf.rb : 設定ファイル

site_name = "suzaku_mini"
image_file_directry = "/suzaku_mini/images/"

test_mode    = false

# MySQL データベース接続パラメータ
host         = "localhost"
userid       = "suzaku_mini"
password     = "xxxxxxxx"
database     = "suzaku_mini"

# MySQL データベース接続パラメータ
# (create/drop database)
root_userid  = "root"
root_password = "zzzzzzzz"

# ホームページ巡回時の設定
interval     = 1800
time_limit   = 180
start_level  = 1
max_level    = 3
max_continue = 20
tmp_dir      = "tmp"
log_dir      = "log"
log_out      = true
limit_in_same_site = true
message_out  = true
force        = false
auto_delete  = true

# サイトのカテゴリー文字列
01 = "カテゴリー１"
02 = "カテゴリー２"

# 表示色
text_color        = "#333333"
bg_color          = "#FFFFFF"
link_color        = "#0000FF"
alink_color       = "#0099FF"
vlink_color       = "#800080"
result_color      = "#990000"
score_color       = "#DD6600"
info_color        = "#999999"
table_color       = "#CCCCCC"

# 表示色(管理者モード)
normal_msg_color  = "#006666"
error_msg_color   = "#CC0000"
