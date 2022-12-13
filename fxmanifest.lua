fx_version 'cerulean'
game 'gta5'

description 'GCT Car GPS System'
version '1.0.0'

escrow_ignore = {
	'config.lua'
}

shared_scripts {
	'@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua'
}

lua54 'yes'