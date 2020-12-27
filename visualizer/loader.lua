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
    loading.setvalue({tex = "Chargement des statistiques...", per = 0, alpha = 1})
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

        loading.setvalue({tex = "Loading avatars..."})
        local total_avatars = table.length(names)
        -- load avatars
        for k,v in pairs(names) do
            loading.setvalue({per = k / total_avatars * 100})
            local file_name = "avatars/" .. v .. ".png"
            if love.filesystem.getInfo(file_name) then
                avatars[v] = love.graphics.newImage(file_name)

                colors[v] = average_color(love.image.newImageData(file_name))
            else
                colors[v] = {love.math.random(), love.math.random(), love.math.random()}
            end
        end

        loading.setvalue({tex = "Terminé!", fadeout = true, per = 100})
    end

    if stats and loading.alpha() <= 0 then
        gamestate.switch(menu, stats, avatars, colors, value_to_see)
    end
end

function stats_loader:draw()
    loading.draw()
end

return stats_loader