local json = require("libs/json")
-- https://www.love2d.org/wiki/lua-https
local https = require("https")

local dht_file = ...

love.filesystem.createDirectory("avatars")

print("Downloading avatars in background...")

local file = io.open(dht_file, "rb")
local content = file:read()
local dht = json.decode(content)

for user_id, user in pairs(dht.meta.users) do
    if user.avatar ~= nil then
        local avatar_url = "https://cdn.discordapp.com/avatars/" .. user_id .. "/" .. user.avatar .. ".png"
    
        if not love.filesystem.getInfo("avatars/" .. user.name .. ".png") then

            print("Downloading avatar of " .. user.name)
            local code, res, headers = https.request( avatar_url )

            if code == 200 then
                local success = love.filesystem.write("avatars/" .. user.name .. ".png", res)

                if not success then
                    print(code, json.encode(headers))
                end
            else
                print("Error downloading avatar", user_id, user.avatar)
            end

        end
    end
end

print("Done downloading avatars!")