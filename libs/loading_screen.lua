local L = {}

local function rf(min, max, decimals) return math.random(min * 10^decimals, max * 10^decimals) / 10^decimals end
local function round(num, decimals) return math.floor(num * 10^(decimals or 0) + 0.5) / 10^(decimals or 0) end
local function inOutBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    s = s * 1.525
    t = t / d * 2
    if t < 1 then
        return c / 2 * (t * t * ((s + 1) * t - s)) + b
    else
        t = t - 2
        return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
    end
end
local function stringcount(string, patern)
    local count = 0
    for i in string.gmatch(string, patern) do count = count + 1 end
    return count
end
local function printc(text, x, y, w, h) -- center print
    text = text or ""
    local font = love.graphics.getFont()
    local vspace  = font:getHeight(text) * math.ceil(font:getWidth(text) / w)
    local hspace = font:getWidth(text)
    love.graphics.printf(text, x, y + h / 2 - vspace / 2, w, "center")
end
local function between(v, i, a) return math.max(math.min(v, a), i) end

local dots = {}
local window_width, window_height = 0, 0
local font = love.graphics.newFont(18)
local text, percentage, desiredpercentage = "", 0, 0
local alpha, alpha_speed = 0, 2
local maxsize = 32
local maxtime = .5
local bars, fadeout = true, false

function L.init()
    dots = {}

    for i = 1, 5 do
        local dir = math.random(0, 1)
        if dir == 1 then dir = true else dir = false end

        dots[i] = {
            colors = {rf(0, 1, 2), rf(0, 1, 2), rf(0, 1, 2)},
            changing = math.random(1, 3),
            changing_direction = false,
            size = math.random(0, 1) * maxsize,
            dir = dir,
            time = rf(0, maxtime, 2),
            parent = math.random(1, 5),
        }
    end

    window_width, window_height = love.window.getMode()
end

function L.resize(w, h)
    window_width, window_height = w, h
end

function L.update(dt)
    local diff = desiredpercentage - percentage
    percentage = percentage + diff * dt * 10

    if fadeout then alpha = math.max(alpha - dt * alpha_speed, 0)
    else alpha = math.min(alpha + dt * alpha_speed, 1) end

    for i, dot in pairs(dots) do
        if not bars and dot.dir then
            dot.dir = false
            dot.time = 0
        end
        
        if dot.time >= maxtime * 2 and dots[dot.parent].time >= maxtime * 4 then
            if not bars then
                dot.dir = false
            else
                dot.dir = not dot.dir
                dot.time = 0
            end
            dot.parent = math.random(1, 5)
        elseif dot.time <= maxtime then
            if dot.dir then
                dot.size = inOutBack(dot.time, 0, maxsize, maxtime, 2)
            elseif not dot.dir then
                dot.size = inOutBack(dot.time, maxsize, -maxsize, maxtime, 2)
            end
        end

        dot.time = dot.time + dt * rf(1, 1.5, 2)

        -- color stuff
        local changing_color = dot.changing
        local color = dot.colors[changing_color]
        local color_dir = dot.changing_direction

        if color_dir then
            dot.colors[changing_color] = color + rf(0, dt, 6)
            if color >= 0.8 then
                dot.changing_direction = not color_dir
                dot.changing = math.random(1, 3)
            end
        else
            dot.colors[changing_color] = color - rf(0, dt, 6)
            if color <= 0.2 then
                dot.changing_direction = not color_dir
                dot.changing = math.random(1, 3)
            end
        end
    end
end

function L.setvalue(tbl)
    tbl.per = math.min(tbl.per or percentage, 100)
    
    text, desiredpercentage = tbl.tex or text, tbl.per

    if tbl.bars == nil then bars = true
    else bars = tbl.bars end

    if tbl.fadeout == nil then fadeout = false
    else fadeout = tbl.fadeout end

    alpha = tbl.alpha or alpha
end

function L.alpha() return alpha end

function L.draw()
    local field_width, field_height, lines = round(font:getWidth(text)) + 10, round(font:getHeight()), stringcount(text, "\n") + 1

    love.graphics.push("transform")
    love.graphics.translate(round(window_width / 2 - (6 * 24) / 2), round(window_height / 2 - 24 / 2))
    
    --  bars
    for i, dot in pairs(dots) do
        local r, g, b = unpack(dot.colors)
        local s = dot.size
        love.graphics.setColor(r, g, b, alpha)
        love.graphics.rectangle("fill", i * 24 - 4, 24 - (16 + s) / 2, 8, 8 + s, 5)
    end

    love.graphics.pop()

    -- field background
    local hw, hh, hf = round(window_width / 2), round(window_height / 2), round(field_width / 2)
    love.graphics.setColor(.25, .25, .25, alpha)
    love.graphics.rectangle("fill", hw - hf, hh + maxsize + 16, field_width + 1, field_height * lines + 10, 2)

    -- percentage bar
    if percentage ~= 0 then
        love.graphics.line(hw - hf + 1, hh + 48, hw + hf - 1, hh + maxsize + 16)
        love.graphics.setColor(.75, .75, .75, alpha)
        love.graphics.line(hw - hf + 1, hh + 48, hw - hf + percentage * (field_width / 100), hh + maxsize + 16)
    end

    -- field text
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, alpha)
    printc(text, hw - hf, hh + (field_height * lines) / lines + field_height + 5, field_width, field_height * lines + 10)
end

return L