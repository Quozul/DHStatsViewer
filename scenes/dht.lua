local buttons, previous_gs = {}
local dht = {}
local loading = require("libs/loading_screen")
loading.init()

local thread, channel, thread_avatars
function dht:enter(previous)
    previous_gs = previous
    thread = love.thread.newThread( "threads/dht_to_stats.lua" )
    thread_avatars = love.thread.newThread( "threads/avatar_from_dht.lua" )
    channel = love.thread.newChannel()
    loading.setvalue({tex = "Déposez votre historique de conversation", per = 0, bars = false})
end

function dht:filedropped(file)
    if not thread:isRunning() then
        local filename = file:getFilename()
        print("File dropped")
        thread:start( filename, channel )
        --thread_avatars:start( filename )
        loading.setvalue({bars = true})
    else
        print("Can't drop file, a file is already being analyzed")
    end
end

function dht:keypressed(key)
    if not thread:isRunning() and key == "escape" then
        gamestate.switch(previous_gs)
    end
end

function dht:update(dt)
    loading.update(dt)

    local info = love.thread.getChannel( "channel" ):pop()
    if info then loading.setvalue(info) end

    if loading.alpha() <= 0 then gamestate.switch(previous_gs) end
end

function dht:draw()
    loading.draw()
    if not thread:isRunning() then
        love.graphics.print("Appuyez sur echap pour revenir en arrière.")
    else
        love.graphics.print("Attendez la fin de l'analyse.")
    end
end

return dht