local info_channel, done_channel, value_to_see = ...

local json = require("libs/json")
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

local raw_stats = json:decode(love.filesystem.read("all_stats.json"))

local names = {}
local avg_pos = {}
local stats, avatars, colors = {}, {}, {}
local total_days = tablelength(raw_stats)
local indexes, inversed_indexes = {}, {}

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
        positions[name] = {msg = 0, days = 1, total = msg}
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
        table.insert(a, name) end
   for pos, name in spairs(a) do
        positions[name].pos = pos

        if not avg_pos[name] then
            avg_pos[name] = {}
            --avg_pos[name][pos] = total_days - positions[name].days + 1
        end
        if not avg_pos[name][pos] then avg_pos[name][pos] = 0 end
        avg_pos[name][pos] = avg_pos[name][pos] + 1

        local avg = 0
        for pos, count in pairs(avg_pos[name]) do
            avg = avg + pos * count
        end

        positions[name].avg_pos = avg / total
    end

    table.insert( stats, {date = k, total = total, highest = highest, positions = positions} )

    love.thread.getChannel( "info_channel" ):push({per = indexes[k] / total_days * 100})
    --print(indexes[k] / total_days * 100 .. "%")
end

local success = love.filesystem.write("stats.json", json:encode(stats))

love.thread.getChannel( "done_channel" ):push({stats = stats, names = names})
love.thread.getChannel( "info_channel" ):push({per = 1, fadeout = true})
print("Done!")