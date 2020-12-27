local json = require("libs/json")
-- https://love2d.org/forums/viewtopic.php?f=4&t=85389&start=10#p222288
local https = require("ssl.https")

local dht_file, channel = ...
local output_dir = love.filesystem.getSaveDirectory()

love.filesystem.createDirectory("avatars")

print("Input file: " .. dht_file)
print("Output directory: " .. output_dir)

local file = io.open(dht_file, "r")
local content = io.open(dht_file, "r"):read()
local dht = json:decode(content)

for user_id, user in pairs(dht.meta.users) do
    if user.avatar ~= nul then
        local avatar_url = "https://cdn.discordapp.com/avatars/" .. user_id .. "/" .. user.avatar .. ".png"
    
        if not love.filesystem.getInfo("avatars/" .. user.name .. ".png") then

            print("Downloading avatar of " .. user.name)
            local res, code, headers, status = https.request( avatar_url )
            
            if res ~= "" then
                local success = love.filesystem.write("avatars/" .. user.name .. ".png", res)

                if not success then
                    print(code, json:encode(headers), status)
                end
            elseif res == "" then
                print("Error downloading avatar")
            end

        end
    end
end