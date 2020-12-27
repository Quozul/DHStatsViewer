local filename, channel = ...

local JSON = require("libs/json")
-- https://love2d.org/forums/viewtopic.php?f=4&t=85389&start=10#p222288
local https = require("ssl.https")
love.graphics = {}
require("libs/utils")
require("love.image")

love.thread.getChannel( "channel" ):push( {tex = "Chargement du fichier..."} )
local package = love.filesystem.mount(filename, "package")

love.thread.getChannel( "channel" ):push( {tex = "Chargement des utilisateurs..."} )
local raw_user_json = JSON:decode(love.filesystem.read("package/account/user.json"))
local relationships = raw_user_json.relationships
local users = {}

for index, user in pairs(relationships) do
    local avatar = user.user.avatar

    table.insert(users, index, {
        id = user.id,
        name = user.user.username,
        discriminator = user.user.discriminator,
        avatar = avatar,
    })

    if avatar then
        users[index].avatar_url = "https://cdn.discordapp.com/avatars/" .. user.id .. "/" .. avatar .. ".png"
    end
end

love.thread.getChannel( "channel" ):push( {tex = "Téléchargement des avatars..."} )
if not love.filesystem.getInfo("avatars") then
    love.filesystem.createDirectory("avatars")
end

local uses_length = table.length(users)
for index, user in pairs(users) do
    love.thread.getChannel( "channel" ):push( {per = index / uses_length * 100} )
    print(index / uses_length * 100)

    if user.avatar_url and not love.filesystem.getInfo("avatars/" .. user.name .. ".png") then
        print("Downloading avatar of " .. user.name)
        local res, code, headers, status = https.request( user.avatar_url )
        if res ~= "" then
            local success = love.filesystem.write("avatars/" .. user.name .. ".png", res)

            if not success then
                print(code, headers, status)
            end
        else
            print("Avatar might have changed, can't download it")
        end
    end
end

love.thread.getChannel( "channel" ):push( {tex = "Terminé!", fadeout = true, per = 0} )