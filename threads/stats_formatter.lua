local info_channel, done_channel, value_to_see = ...

local bitser = require("libs/bitser")
require("love.graphics")
require("love.image")
require("love.math")
require("love")

local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then table.sort(keys, function(a,b) return order(t, a, b) end) else table.sort(keys) end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then return keys[i], t[keys[i]] end
    end
end
local function tablelength(tbl)
    local count = 0
    for k,_ in pairs(tbl) do
        count = count + 1
    end
    return count
end
local function tablecontains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
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

local raw_stats = bitser.loads(love.filesystem.read("raw_stats.bin"))

local names = {}
local avg_pos = {}
local stats, avatars, colors = {}, {}, {}
local total_days = tablelength(raw_stats)
local indexes, inversed_indexes = {}, {}
local days = {}

local i = 1
for k in spairs(raw_stats) do
    indexes[k] = i
    i = i + 1
end

for k, i in spairs(indexes) do inversed_indexes[i] = k end

local close_total_span = 30
for k,v in spairs(raw_stats) do
    local total = 0
    local highest = 0

    -- count total messages
    for i,p in pairs(v) do total = total + p end

    local positions = {}
    local total = 0
    for name, msg in spairs(v) do
        if days[name] == nil then
            days[name] = 0
        end
        days[name] = days[name] + 1

        positions[name] = {msg = 0, days = days[name], total = msg}

        total = total + msg

        -- get total for list 5 days
        local delta = raw_stats[k][name] - (raw_stats[inversed_indexes[math.max(indexes[k]-close_total_span, 1)]][name] or 0)

        positions[name].close_avg = delta / close_total_span
        -- print(positions[name].close_avg)
        positions[name].avg = msg / positions[name].days

        -- set highest value
        local p = positions[name][value_to_see] -- change here for highest
        if highest < p then highest = p end
        total = total + msg

        -- add username to table
        if not tablecontains(names, name) then table.insert(names, name) end
    end

    -- add position
    local a = {}
    for name, value in spairs(positions, function(t,a,b) return t[b][value_to_see] < t[a][value_to_see] end) do -- change here for position
        table.insert(a, name)
    end

    for pos, name in spairs(a) do
        positions[name].pos = pos
    end

    table.insert( stats, {date = k, total = total, highest = highest, positions = positions} )

    love.thread.getChannel( "info_channel" ):push({per = indexes[k] / total_days * 50})
end

local success = love.filesystem.write("stats.bin", bitser.dumps(stats))

love.thread.getChannel( "done_channel" ):push({stats = stats, names = names})
love.thread.getChannel( "info_channel" ):push({per = 1, fadeout = true})
print("Done!")