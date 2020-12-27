function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function vpairs(t, f)
    local a = {}
    for _, n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
    end
    return iter
end

function table.length(tbl)
    local count = 0
    for k,_ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function table.contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function average_color(imagedata)
    local w, h = imagedata:getDimensions()
    local ar, ag, ab = 0, 0, 0

    for x = 0, w - 1 do
        for y = 0, h - 1 do
            local r, g, b = imagedata:getPixel(x, y)
            ar = ar + r
            ag = ag + g
            ab = ab + b
        end
    end

    local s = w * h
    return {ar / s, ag / s, ab / s}
end

-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)
function linear(t, b, c, d)
    return c * t / d + b
end
local sin = math.sin
local cos = math.cos
local pi = math.pi
function inOutSine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

function string:count(patern)
    local count = 0
    for i in string.gmatch(self, patern) do
        count = count + 1
    end
    return count
end

function love.graphics.printc(text, x, y, w, h)
    text = text or ""
    local font = love.graphics.getFont()
    local vspace  = font:getHeight(text) * math.ceil(font:getWidth(text) / w)
    local hspace = font:getWidth(text)

    love.graphics.printf(text, x, y + h / 2 - vspace / 2, w, "center")
end