local buttons, previous_gs = {}
local package = {}
local loading = require("libs/loading_screen")
loading.init()

local thread, channel
function package:enter(previous)
    previous_gs = previous
    thread = love.thread.newThread( "threads/avatar_from_package.lua" )
    channel = love.thread.newChannel()
    loading.setvalue({tex = "Déposez votre paquet Discord", per = 0, bars = false})
end

function package:filedropped(file)
    if not thread:isRunning() then
        local filename = file:getFilename()
        print("File dropped")
        thread:start( filename, channel )
        loading.setvalue({bars = true})
    else
        print("Can't drop file, a file is already being analyzed")
    end
end

function package:keypressed(key) gamestate.switch(previous_gs) end

function package:update(dt)
    loading.update(dt)

    local info = love.thread.getChannel( "channel" ):pop()
    if info then loading.setvalue(info) end

    if loading.alpha() <= 0 then gamestate.switch(previous_gs) end
end

function package:draw()
    loading.draw()
    love.graphics.print("Appuyez sur n'importe quelle touche pour revenir en arrière.")
end

return package