resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

-- resource_type 'gametype' { name = 'Casino: Blackjack!' }

client_script 'casino_client.lua'
client_script 'casino.lua'
server_script 'casino_server.lua'

export 'get_namespace'

-- client_script 'casinoplayer_client.lua'
-- server_script 'casinoplayer_server.lua'