fx_version 'cerulean'
game 'gta5'

author 'Bulldogred'
version '1.0.1'
description 'Black Market Dealer'
lua54 'yes'

client_scripts {
'client.lua'
}

server_scripts {
'server.lua'
}
-- NUI files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
dependencies {
    'ox_inventory',
    'ox_target',
  --  'cd_dispatch'
}