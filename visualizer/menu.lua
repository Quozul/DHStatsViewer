local buttons, previous_gs = {}
local menu = {}

require("libs/utils")
local points = require("visualizer.points")
local bars = require("visualizer.bars")

local big_font = love.graphics.newFont(32)
local small_font = love.graphics.newFont(12)
local max_hover_time = 1
local stats = {}

local value_to_see = "avg"
local value_to_see_descriptions = {
    avg = "Moyenne de messages envoyés par jours",
    msg = "Messages envoyés ce jour",
    total = "Messages totaux envoyés",
    days = "Jours de parole"
}

local w, h

function menu:enter(previous, stats, avatars, colors, v)
    previous_gs = previous

    w, h = love.graphics.getDimensions()
    value_to_see = v
    buttons.points = {
        x = 10,
        y = 110,
        w = w / 2 - 20,
        h = h - 120,
        click = function() gamestate.switch(points, stats, avatars, colors, value_to_see) end,
        text = "Courbes dynamiques",
        color = {0, 0, 255},
        hover_text = "",
        hover = false,
        hover_time = 0
    }
    buttons.bars = {
        x = w / 2 + 10,
        y = 110,
        w = w / 2 - 20,
        h = h - 120,
        click = function() gamestate.switch(bars, stats, avatars, colors, value_to_see) end,
        text = "Barres dynamiques",
        color = {0, 0, 255},
        hover_text = "",
        hover = false,
        hover_time = 0
    }
    buttons.back = {
        x = 10,
        y = 10,
        w = w - 20,
        h = 90,
        click = function() gamestate.switch(require("scenes.menu")) end,
        text = "Menu principal",
        color = {0, 0, 255},
        hover_text = "",
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

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", mx, my, 500, 100)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printc(v.hover_text, mx, my, 500, 100)
        end
    end
end

return menu