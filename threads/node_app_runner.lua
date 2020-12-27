local dht_file, channel = ...
local output_dir = love.filesystem.getSaveDirectory()

print("Input file: " .. dht_file)
print("Output directory: " .. output_dir)

love.thread.getChannel( "channel" ):push( {tex = "Analyse du fichier..."} )
love.filesystem.createDirectory("users")

local handle = io.popen("node ../main.js in=" .. dht_file .. " out=" .. output_dir)
local result = handle:read("*a")
handle:close()

print(result)

love.thread.getChannel( "channel" ):push( {tex = "Terminé!", bars = false, fadeout = true} )