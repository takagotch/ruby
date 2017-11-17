require 'json'

data = [1, 2.0, {'key' => 'value'}, nil, true, false]

# JSONとしてダンプする
# JSON.dump(data) でもよい
p json = data.to_json # => "[1,2.0,{ \"key \": \"value \"},null,true,false]"

# ロードする
p JSON.load(json) # => [1, 2.0, {"key"=>"value"}, nil, true, false]
