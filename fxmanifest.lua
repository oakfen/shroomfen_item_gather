fx_version "cerulean"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

author "Shroom + Oakfen"
description "Loose item gathering - gather items at coordinates with cooldown"
version "1.0.0"

lua54 "yes"

shared_scripts {
  "@jo_libs/init.lua",
  "shared/config.lua",
}

client_scripts {
  "client/main.lua",
}

server_scripts {
  "server/main.lua",
}

dependencies {
  "jo_libs",
  "vorp_core",
  "vorp_inventory",
}

jo_libs {
  "framework-bridge",
  "prompt",
  "notification",
}
