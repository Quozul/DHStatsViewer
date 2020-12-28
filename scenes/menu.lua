local buttons = {}
local menu = {}

require("libs/utils")
local dht = require("scenes.dht")
local vis_menu = require("visualizer.pre_menu")

local big_font = love.graphics.newFont(32)
local small_font = love.graphics.newFont(12)
local max_hover_time = 1

function menu:enter(previous)
    local w, h = love.graphics.getDimensions()
    buttons.add_discord_dht = {
        x = 10,
        y = 10,
        w = w / 2 - 20,
        h = (h / 3) * 2 - 20,
        click = function() gamestate.switch(dht) end,
        text = "Add Discord History",
        color = {0, 0, 1},
        hover_text = "Add your DHT file.",
        hover = false,
        hover_time = 0
    }
    buttons.read_current = {
        x = w / 2 + 10,
        y = 10,
        w = w / 2 - 20,
        h = (h / 3) * 2 - 20,
        click = function() gamestate.switch(vis_menu) end,
        text = "Play loaded statistics",
        color = {0, 1, 0},
        hover_text = "View the statistics with animated graphs.",
        hover = false,
        hover_time = 0
    }
    --[[buttons.clean_avatar_cache = {
        x = 10,
        y = (h / 3) * 2 + 10,
        w = w / 2 - 20,
        h = h / 3 - 20,
        click = function() love.filesystem.remove("avatars") end,
        text = "Effacer les avatars téléchargés",
        color = {1, 0, 0},
        hover_text = "Supprime les avatars téléchargés, permet de les télécharger à nouveau.",
        hover = false,
        hover_time = 0
    }]]
    buttons.share = {
        x = w / 2 + 10,
        y = (h / 3) * 2 + 10,
        w = w / 2 - 20,
        h = h / 3 - 20,
        click = function()
            love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
        end,
        text = "Open save folder/share",
        color = {1, 0, 0.5},
        hover_text = "Open the folder with the statitics file.",
        hover = false,
        hover_time = 0
    }
end

function menu:update(dt)
    for id, v in pairs(buttons) do
        if v.hover then
            v.hover_time = math.min(v.hover_time + dt, max_hover_time)
        else
            v.hover_time = math.max(v.hover_time - dt, 0)
        end
    end
end

function menu:mousepressed(x, y)
    for id, v in pairs(buttons) do
        if v.hover then
            v.click()
        end
    end
end

function menu:mousemoved(x, y, dx, dy, istouch)
    for id, v in pairs(buttons) do
        if x < v.x+v.w and v.x < x and y < v.y+v.h and v.y < y then
            v.hover = true
        else
            v.hover = false
        end
    end
end

function menu:draw()
    love.graphics.setFont(big_font)
    for id, v in pairs(buttons) do
        local c = v.hover_time / 4
        love.graphics.setColor(v.color[1] + c, v.color[2] + c, v.color[3] + c)
        love.graphics.rectangle("fill", v.x, v.y, v.w, v.h, 10)
        local brightness = 0.2126*v.color[1] + 0.7152*v.color[2] + 0.0722*v.color[3]

        if brightness > 0.5 then
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end

        -- love.graphics.printf(v.text, v.x, v.y + v.h / 2, v.w, "center")
        love.graphics.printc(v.text, v.x, v.y, v.w, v.h)
    end

    love.graphics.setFont(small_font)
    for id, v in pairs(buttons) do
        if v.hover and v.hover_text ~= "" then
            local mx, my = love.mouse.getPosition()
            local w, h = v.w / 3 * 2, v.h / 3 * 2

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", mx, my, w, h)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printc(v.hover_text, mx, my, w, h)
        end
    end
end

return menu