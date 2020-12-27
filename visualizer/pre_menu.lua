local buttons = {}
local menu = {}
local previous_gs

require("libs/utils")
local loader = require("visualizer.loader")

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

function menu:enter(previous, stats, avatars, colors)
    previous_gs = previous

    w, h = love.graphics.getDimensions()
    buttons.avg = {
        x = 10,
        y = 10,
        w = w / 2 - 20,
        h = h / 3 * 2 - 20,
        click = function()
            value_to_see = "avg"
            gamestate.switch(loader, "avg")
        end,
        text = "Moyenne de messages",
        color = {0, 255, 0},
        hover_text = "Moyenne de messages envoyés par jours",
        hover = false,
        hover_time = 0
    }
    buttons.close_avg = {
        x = 10,
        y = h / 3 * 2 + 10,
        w = w / 2 - 20,
        h = h / 3 - 20,
        click = function()
            value_to_see = "close_avg"
            gamestate.switch(loader, "close_avg")
        end,
        text = "Moyenne de messages récente",
        color = {0, 255, 0},
        hover_text = "Moyenne de messages envoyés par jours sur les 5 derniers jours",
        hover = false,
        hover_time = 0
    }
    buttons.total = {
        x = w / 2 + 10,
        y = 10,
        w = w / 2 - 20,
        h = h - 20,
        click = function()
            value_to_see = "total"
            gamestate.switch(loader, "total")
        end,
        text = "Messages totaux",
        color = {0, 255, 0},
        hover_text = "Nombre de messages totaux envoyés",
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

function menu:keypressed(key)
    gamestate.switch(previous_gs)
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