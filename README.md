# DHStatsViewer

## What is it?
A long time ago (in 2018), I wanted to see how much I use Discord, so I made this.

## Usage
[Love2d](love2d.org) is required to run this. Simply install it and run `love .`

1. Scan and download your Discord history with [Discord History Tracker](https://dht.chylex.com/).
2. Open the app, click on the "Add Discord History" button
3. Drag-drop your DHT file
4. Once done, you can click on "Play loaded statistics" to view the graphs

### Note on using the tracker
DHT has been updated, this software requires the history to be in JSON format.  
It is known to be compatible with the [browser only version](https://dht.chylex.com/browser-only/) as the new desktop version provides a binary file as output.

## Dependencies
* [brunoos/luasec](https://github.com/brunoos/luasec) — [compiled](https://love2d.org/forums/viewtopic.php?f=4&t=85389&start=10#p222288)

## Libraries
* [gvx/bitser](https://github.com/gvx/bitser) - Serializes and deserializes Lua values with LuaJIT
* [Tieske/date](https://github.com/Tieske/date) - Date & Time module for Lua 5.x
* [vrld/gamestate](https://github.com/vrld/hump) - Easy gamestate management
* [rxi/json](https://github.com/rxi/json.lua) - A lightweight JSON library for Lua  

## Compiling
Read [Game Distribution](https://love2d.org/wiki/Game_Distribution) page on Love2D.org