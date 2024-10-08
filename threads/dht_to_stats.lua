-- https://github.com/rxi/json.lua
local json = require("libs/json")
local date = require("libs/date")
local bitser = require("libs/bitser")

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

local dht_file, channel = ...

print("Input file: " .. dht_file)

love.thread.getChannel( "channel" ):push( {tex = "Opening file...", per = 20} )
print("Opening file...")
local file = io.open(dht_file, "rb")

love.thread.getChannel( "channel" ):push( {tex = "Reading file...", per = 40} )
print("Reading file...")
local content = file:read()

love.thread.getChannel( "channel" ):push( {tex = "Decoding file...", per = 60} )
print("Decoding file...")
local dht = json.decode(content)

love.thread.getChannel( "channel" ):push( {tex = "Analysing file...", per = 80} )
print("Analysing file...")

local result = {}
local i = 0
local length = 0
for k,v in pairs(dht.data) do
    length = length + 1
end


-- Count messages (per day)
for channel_id, messages in pairs(dht.data) do
    local server_index = dht.meta.channels[channel_id].server + 1
    local type = dht.meta.servers[server_index].type

    if type == "DM" then
        local channel_name = dht.meta.channels[channel_id].name
        print("Channel: " .. channel_name .. ", type: " .. type)

        for message_id, message in pairs(messages) do
            local x = date(message.t / 1000 + (3600 * 2)):fmt("%Y/%m/%d")

            if result[x] == nil then
                result[x] = {}
            end

            if result[x][channel_name] == nil then
                result[x][channel_name] = 0
            end

            result[x][channel_name] = result[x][channel_name] + 1
        end
    end

    i = i + 1
    love.thread.getChannel( "channel" ):push( {tex = "Analysing file...", per = 80 + i / length * 20} )
end

local output = {}

-- Sort messages
print("Sorting...")
for day, value in spairs(result) do
    output[day] = value
end

-- Sum messages
print("Summing...")
local previous_index
for day, value in spairs(output) do
    if previous_index ~= nil then
        local previous_day = output[previous_index]

        for channel_name, message_amount in pairs(previous_day) do

            if output[day][channel_name] ~= nil then
                output[day][channel_name] = output[day][channel_name] + message_amount
            else
                output[day][channel_name] = message_amount
            end

        end

    end

    previous_index = day
end

print("Saving...")
love.filesystem.write("raw_stats.bin", bitser.dumps(output))

print("Done!")
love.thread.getChannel( "channel" ):push( {tex = "Done!", bars = false, fadeout = true} )