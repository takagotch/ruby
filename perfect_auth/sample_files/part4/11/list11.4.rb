require 'yaml'

yaml_string = <<EOS
---
  remote:
    host: localhost
    port: 22
    ssh: true
    username: user
    password: null
EOS

# YAMLをオブジェクトとしてロードする
p setting = YAML.load(yaml_string)
# => {"remote"=>{"host"=>"localhost", "port"=>22, "ssh"=>true, "username"=>"user", "password"=>nil}}

# 内容を変更
setting['remote'].update('host' => 'example.com')

# オブジェクトをYAMLとしてダンプ（YAML.dumpを使う）
p YAML.dump(setting)
# => "---\nremote:\n host: example.com\n port: 22\n ssh: true\n username: user\n password: \n"

# 内容をYAMLとしてダンプ（Object#to_yamlを使う）
p setting.to_yaml # => （YAML.dumpと同じ結果）
