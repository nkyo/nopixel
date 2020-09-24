resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

SetResourceInfo('uiPage', 'html/index.html')
ui_page 'html/index.html'



client_script 'blackjackDealer_client.lua'
client_script 'casino_client.lua'
-- client_script 'cardsDealer_client.lua'

server_script 'casino_server.lua'

files
{
    'html/index.html',
    'html/scripts.js',
    'html/styles.css',
}

exports {
    'getChipBalance'
}
