# 2D_Craft
Para LOVE 2D
---------------------------------------------------------------------------
VERSÂO 0.8
Movimentação
Basico, um personagem que anda pelo mata sendo persseguido por uma slime comsitema de camera incluso, iventario, Barra de itens, sistema de morte
Hud barra de vida,
----------------------------------------------------------------------------
Sistema de Controle
Movimentar: WASD
Ataque: C
Coleta: E
Drop: Q
Zoom+: +
Zoom-: -

----------------------------------------------------------------------------
Iventario
Pegar e solta com Mouse1

sistema pronto de 
Mods prontos Blocos,decor,flowers,health,hotbar,inimigos,inventory,player,tools,ui

----------------------------------------------------------------------------
Estrutura de diretorio
meujogo/
├── assets/
│   ├── Mapa.json
│   └── sprites/
│       └── ...
├── lib/
│   ├── bump.lua
│   ├── camera.lua
│   ├── gamestate.lua
│   └── sti/
│       ├── atlas.lua
│       ├── graphics.lua
│       ├── init.lua
│       └── utils.lua
├── mods/
│   └── ...
├──conf.lua
├──iniciar_jogo.bat
└── main.lua

----------------------------------------------------------------------------
Dependencias 
Windows 7
Bobliotecas 
--bump + gamestate
	meujogo/lib/bump.lua
	meujogo/lib/camera.lua
 meujogo/lib/gamestate.lua
----------------------------------------------------------------------------
Biblioteca
camera hump-master.zip
Link https://github.com/vrld/hump

Fisica
Arquivivo bump.lua-master
Link https://github.com/kikito/bump.lua
