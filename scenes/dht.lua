local buttons, previous_gs = {}
local dht = {}
local loading = require("libs/loading_screen")
loading.init()

local thread, channel
function dht:enter(previous)
    previous_gs = previous
    thread = love.thread.newThread( "threads/node_app_runner.lua" )
    channel = love.thread.newChannel()
    loading.setvalue({tex = "Déposez votre historique de conversation", per = 0, bars = false})
end

function dht:filedropped(file)
    if not thread:isRunning() then
        local filename = file:getFilename()
        print("File dropped")
        thread:start( filename, channel )
        loading.setvalue({bars = true})
    else
        print("Can't drop file, a file is already being analyzed")
    end
end

function dht:keypressed(key) gamestate.switch(previous_gs) end

function dht:update(dt)
    loading.update(dt)

    local info = love.thread.getChannel( "channel" ):pop()
    if info then loading.setvalue(info) end

    if loading.alpha() <= 0 then gamestate.switch(previous_gs) end
end

function dht:draw()
    loading.draw()
    love.graphics.print("Appuyez sur n'importe quelle touche pour revenir en arrière.")
end

return dht