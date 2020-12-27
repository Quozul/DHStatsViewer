gamestate = require("libs.gamestate")

local menu = require("scenes.menu")

function love.load(...)
    love.keyboard.setKeyRepeat(true)
    love.graphics.setBackgroundColor(.1, .1, .1)
    gamestate.registerEvents()
    gamestate.switch(menu)
end