local buttons = {}
local stats_loader = {}

local value_to_see = "avg"
local value_to_see_descriptions = {
    avg = "Moyenne de messages envoyés par jours",
    msg = "Messages envoyés ce jour",
    total = "Messages totaux envoyés",
    days = "Jours de parole"
}

local loading = require("libs/loading_screen")
local menu = require("visualizer.menu")
require("libs/utils")
loading.init()

local thread, info_channel, done_channel
function stats_loader:enter(previous, v)
    value_to_see = v
    thread = love.thread.newThread( "threads/stats_formatter.lua" )
    info_channel, done_channel = love.thread.newChannel(), love.thread.newChannel()
    loading.setvalue({tex = "Loading...", per = 0, alpha = 1})
    thread:start(info_channel, done_channel, value_to_see)
end

local stats = {}
local avatars, colors = {}, {}
function stats_loader:update(dt)
    loading.update(dt)

    local info = love.thread.getChannel( "info_channel" ):pop()
    if info then
        loading.setvalue(info)
    end

    local done = love.thread.getChannel( "done_channel" ):pop()
    if done then
        stats = done.stats
        local names = done.names

        loading.setvalue({tex = "Loading..."})
        print("Loading avatars...")
        local total_avatars = #names

        -- load avatars
        for k,v in pairs(names) do
            local file_name = "avatars/" .. v .. ".png"
            if love.filesystem.getInfo(file_name) then
                local imageData = love.image.newImageData(file_name)
                
                avatars[v] = love.graphics.newImage(imageData)

                colors[v] = average_color(imageData)
            else
                colors[v] = {love.math.random(), love.math.random(), love.math.random()}
            end
        end
    end

    if stats and colors and avatars and loading.alpha() <= 0 then
        gamestate.switch(menu, stats, avatars, colors, value_to_see)
    end
end

function stats_loader:draw()
    loading.draw()
end

return stats_loader