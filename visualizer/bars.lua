local bars, previous_gs = {}
local stats, avatars, colors = {}, {}, {}

require("libs/utils")

local units = {
    avg = "msgs/jours",
    msg = "messages",
    total = "messages",
    days = "jours",
    close_avg = "msgs/jours",
}

local max_width = 0
local max_height = 0

local window_width
local window_height

local height = 32
local font = love.graphics.newFont(height / 4)
local med_font = love.graphics.newFont(height / 2)
local big_font = love.graphics.newFont(32)
local bars_top = 45 - height

local date_str = love.graphics.newText(big_font, "1970/01/01")
local name_text = love.graphics.newText(med_font, "null")
local messages = love.graphics.newText(font, "0")

local cooldown = 0
local days_per_secs = 4
local dir = true
local play = false
local animate = true
local index = 1
local fake_index = 1
local value_to_see
local stats_len = 1

local scroll = 0
local desired_scroll = 0

local knob_selected = false

local local_highest = false
local global_highest = 0
local previous_global_highest = 0

function bars:enter(previous, s, a, c, v)
    stats, avatars, colors, value_to_see = s, a, c, v
    previous_gs = previous
    stats_len = table.length(stats)
    max_width = love.graphics.getWidth() - height
    max_height = love.graphics.getHeight() - 60
    window_width = love.graphics.getWidth()
    window_height = love.graphics.getHeight()
end

local function updateSize()
    max_width = love.graphics.getWidth() - height
    max_height = love.graphics.getHeight() - 60
    window_width = love.graphics.getWidth()
    window_height = love.graphics.getHeight()

    font = love.graphics.newFont(height / 4)
    med_font = love.graphics.newFont(height / 2)
    --big_font = love.graphics.newFont(32)
    bars_top = 45 - height

    name_text:setFont(med_font)
    messages:setFont(font)
end

function bars:update(dt)
    index = round(fake_index)

    -- scroll smoothing
    scroll = scroll + (desired_scroll - scroll) * (dt * 10)
    -- perform rounding
    if math.abs(desired_scroll - scroll) <= .01 then
        scroll = desired_scroll
        if local_highest then
            previous_global_highest = global_highest
        end
    end

    if local_highest then
        for name, user in spairs(stats[index].positions, function(t,a,b) return t[b][value_to_see] > t[a][value_to_see] end) do
            if user.pos + desired_scroll == 1 then
                global_highest = user[value_to_see]
                break
            end
        end
    end

    if not stats[index] or not play then return end

    cooldown = cooldown + dt

    if cooldown >= 1 / days_per_secs then
        if dir then fake_index = fake_index + 1
        else fake_index = fake_index - 1 end
        cooldown = 0
    end

    if index >= stats_len then
        play = false
    end
end

function bars:keypressed(key, scancode, isrepeat)
    if key == "right" then
        play = false
        fake_index = math.min(fake_index + 1, stats_len)
        cooldown = 1
    elseif key == "left" then
        play = false
        fake_index = math.max(fake_index - 1, 1)
        cooldown = 1
    end

    if not isrepeat then
        if key == "space" then
            play = not play
            if not play then
                cooldown = 1
            else
                cooldown = 0
            end
        elseif key == "up" then
            if not dir and days_per_secs <= 0 then
                days_per_secs = 1
                dir = true
            elseif not dir then
                days_per_secs = days_per_secs - 1
            else
                days_per_secs = days_per_secs + 1
            end
        elseif key == "lshift" then
            if not dir and days_per_secs <= 0 then
                days_per_secs = 10
                dir = true
            elseif not dir then
                days_per_secs = days_per_secs - 10
            else
                days_per_secs = days_per_secs + 10
            end
        elseif key == "rshift" then
            if dir and days_per_secs <= 0 then
                days_per_secs = 10
                dir = false
            elseif not dir then
                days_per_secs = days_per_secs + 10
            else
                days_per_secs = days_per_secs - 10
            end
        elseif key == "down" then
            if days_per_secs <= 0 and dir then
                days_per_secs = 1
                dir = false
            elseif not dir then
                days_per_secs = days_per_secs + 1
            else
                days_per_secs = days_per_secs - 1
            end
        elseif key == "a" then
            animate = not animate
        elseif key == "r" then
            index = 1
        elseif key == "escape" then
            gamestate.switch(previous_gs, stats, avatars, colors, value_to_see)
        elseif key == "kp+" then
            height = math.min(height * 2, 128)
            updateSize()
        elseif key == "kp-" then
            height = math.max(height / 2, 16)
            updateSize()
        elseif key == "f11" or key == "f" then
            love.window.setFullscreen(not love.window.getFullscreen())
        elseif key == "l" then
            local_highest = not local_highest
        end
    end
end

function bars:resize(w, h)
    max_width = w - height
    max_height = h - 60
    window_width = w
    window_height = h
end

function bars:wheelmoved(x, y)
    desired_scroll = math.min(math.max(desired_scroll + y, -table.length(stats[index].positions) + 1), 0)
end

function bars:mousepressed(mx, my, button)
    local x = index / stats_len * (window_width - 32) + 16
    local y = window_height - 16

    if not knob_selected and mx > x - 8 and x + 8 > mx and my > y - 8 and y + 8 > my then
        knob_selected = true
        play = false
    elseif mx > 0 and window_width > mx and my > y - 8 and y + 8 > my then
        local px_d = stats_len / (window_width - 32)
        local dx = mx - x -- mouse from knob

        fake_index = math.min(math.max(fake_index + px_d * dx, 1), stats_len)

        knob_selected = true
        play = false
    end
end

function bars:mousereleased(x, y, button)
    knob_selected = false
end

function bars:mousemoved(x, y, dx, dy)
    if knob_selected then
        local px_d = stats_len / (window_width - 32)

        fake_index = math.min(math.max(fake_index + px_d * dx, 1), stats_len)
    end
end

function bars:draw()
    if not stats or not stats[index] then return end

    for name, user in spairs(stats[index].positions, function(t,a,b) return t[b][value_to_see] > t[a][value_to_see] end) do -- change here for position
        local highest = local_highest and global_highest or stats[index].highest
        local value = user[value_to_see] -- change here for value
        local pos = user.pos + scroll
        local per = value / highest
        local width = per
        local y = pos * (height + height / 8) + bars_top
        local msgs_amount = value
        local avg_pos = user.avg_pos
        local avg_pos_y = avg_pos * (height + height / 8) + bars_top

        -- calculate animation
        if play and animate then
            local pre = stats[index].pre_pos[name]
            local pre_per = 0
            
            if pre then
                if (pre.pos + scroll) ~= pos then
                    local pre_y = (pre.pos + scroll) * (height + height / 8) + bars_top
                    y = inOutSine(cooldown, pre_y, y - pre_y, 1 / days_per_secs)
                end

                local pre_value = pre[value_to_see] -- change here for value
                pre_per = pre_value / stats[index].pre_highest
                msgs_amount = round(linear(cooldown, pre_value, value - pre_value, 1 / days_per_secs))

                local pre_avg_pos_y = pre.avg_pos * (height + height / 8) + bars_top
                avg_pos_y = inOutSine(cooldown, pre_avg_pos_y, avg_pos_y - pre_avg_pos_y, 1 / days_per_secs)
            end
            
            width = linear(cooldown, pre_per, per - pre_per, 1 / days_per_secs)
        end
        
        if y < max_height + height and bars_top < y then
            -- calculate brightness
            local brightness = 0.2126*colors[name][1] + 0.7152*colors[name][2] + 0.0722*colors[name][3]
            -- draw bars
            love.graphics.setColor(colors[name])
            love.graphics.rectangle("fill", height, y, width * max_width, height, 2)

            -- draw avatars
            if avatars[name] then
                love.graphics.setColor(1, 1, 1)
                local w, h = avatars[name]:getDimensions()
                love.graphics.draw(avatars[name], 0, y, 0, height / w, height / h)
            else
                love.graphics.rectangle("fill", 0, y, height, height)
            end
            love.graphics.print(user.pos, 0, y)

            -- draw name
            name_text:set(name)
            if brightness > 0.5 then
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.draw(name_text, height + 5, y + round((height - name_text:getHeight()) / 2))

            -- draw messages amount
            messages:set(msgs_amount .. " " .. units[value_to_see])
            local x = math.max(height + width * max_width - messages:getWidth() - 10, height + name_text:getWidth() + 10)
            love.graphics.draw(messages, x, y + round((height - messages:getHeight()) / 2))
        end

        -- draw average position
        --[[if avatars[name] then
            love.graphics.setColor(1, 1, 1, .5)
            love.graphics.draw(avatars[name], max_width, avg_pos_y, 0, height / 128, height / 128)
        else
            love.graphics.rectangle("fill", max_width, avg_pos_y, height, height)
        end]]
    end

    -- draw progress bar
    local x = index / stats_len * (window_width - 32)
    local remaining_time = (stats_len - index) / days_per_secs
    local remaining_seconds = round(remaining_time % 60)
    local remaining_minutes = round((remaining_time - remaining_seconds) / 60)

    local played_time = index / days_per_secs
    local played_seconds = round(played_time % 60)
    local played_minutes = round((played_time - played_seconds) / 60)

    local total_time = stats_len / days_per_secs
    local total_seconds = round(total_time % 60)
    local total_minutes = round((total_time - total_seconds) / 60)

    love.graphics.setColor(.1, .1, .1)
    love.graphics.rectangle("fill", 0, window_height - 48, window_width, 48) -- background

    love.graphics.setColor(1, 1, 1)
    love.graphics.line(16, window_height - 16, window_width - 16, window_height - 16)
    love.graphics.circle("fill", x + 16, window_height - 16, 8)

    local play_time = string.format("%02d:%02d/%02d:%02d", played_minutes, played_seconds, total_minutes, total_seconds)
    love.graphics.print(play_time, 16, window_height - 32)

    -- top informations
    love.graphics.setColor(.1, .1, .1)
    love.graphics.rectangle("fill", 0, 0, window_width, 45) -- background
    local sign = ""
    if not dir then sign = "-" end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Jour: " .. index .. " Fake index: " .. fake_index .. " " .. sign .. days_per_secs .. " jours/secondes", 0, 0)
    love.graphics.print("Messages totaux: " .. stats[index].total .. " " .. round(stats[index].total / index) .. " messages/jours", 0, 15)
    love.graphics.print(love.timer.getFPS() .. " fps Scroll: " .. math.abs(scroll), 0, 30)

    date_str:set(stats[index].date)
    love.graphics.draw(date_str, max_width + height - date_str:getWidth() - 10, 10)
end

return bars