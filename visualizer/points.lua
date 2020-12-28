local points, previous_gs = {}
local stats, avatars, colors = {}, {}, {}

require("libs/utils")

local units = {
    avg = "msgs/jours",
    msg = "messages",
    total = "messages",
    days = "jours",
    close_avg = "msgs/jours",
}

local days_back = 28
local start_index = 1

local font = love.graphics.newFont(1/ days_back * 140)
local med_font = love.graphics.newFont(16)
local big_font = love.graphics.newFont(32)

local date_str = love.graphics.newText(font, "1970/01/01")
local name_text = love.graphics.newText(med_font, "null")
local messages = love.graphics.newText(font, "0")

local width = love.graphics.getWidth()
local height = love.graphics.getHeight()
local display_width = width - width / (days_back + 1)
local bottom = 60
local top = 45
local display_height = height - bottom - top
local days_size = display_width / days_back

local unit_precision = 4
local precision_size = display_height / unit_precision
local unit_text = love.graphics.newText(med_font, "0")

local mode = "points" -- bars, points, smooth

local cooldown = 0
local days_per_secs = 4
local dir = true
local play = false
local animate = true
local index = 1
local fake_index = 1
local value_to_see
local stats_len = 1

function points:enter(previous, s, a, c, v)
    previous_gs = previous
    stats, avatars, colors, value_to_see = s, a, c, v
    stats_len = table.length(stats)
    value_to_see = v
end

local function updateSize()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    display_width = width - width / (days_back + 1)
    display_height = height - bottom - top
    days_size = display_width / days_back
    precision_size = display_height / unit_precision

    font = love.graphics.newFont(math.max(1 / days_back * 140, 1))

    unit_text:setFont(med_font)
    date_str:setFont(font)
    name_text:setFont(med_font)
    messages:setFont(font)
end

function points:update(dt)
    index = round(fake_index)

    if knob_selected then
        love.mouse.setGrabbed(true)
    else
        love.mouse.setGrabbed(false)
    end

    start_index = math.max(index - days_back, 1)
    if not stats[index] or not play then return end

    cooldown = cooldown + dt

    if cooldown >= 1 / days_per_secs then
        if dir then fake_index = fake_index + 1
        else fake_index = fake_index - 1 end
        cooldown = cooldown - 1 / days_per_secs
        index = round(fake_index)
    end

    if index >= stats_len then
        print(index, stats_len)
        play = false
    end

    start_index = math.max(index - days_back, 1)
end

function points:keypressed(key, scancode, isrepeat)
    if key == "right" then
        play = false
        fake_index = math.min(fake_index + 1, stats_len)
        cooldown = 1
        index = math.min(math.max(index, 1), table.length(stats))
    elseif key == "left" then
        play = false
        fake_index = math.max(fake_index - 1, 1)
        cooldown = 1
        index = math.min(math.max(index, 1), table.length(stats))
    elseif key == "kp+" then
        days_back = math.min(days_back + 1, 365)
        updateSize()
    elseif key == "kp-" then
        days_back = math.max(days_back - 1, 7)
        updateSize()
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
        end
    end
end

function points:mousepressed(mx, my, button)
    local x = index / stats_len * (width - 32) + 16
    local y = height - 16

    if not knob_selected and mx > x - 8 and x + 8 > mx and my > y - 8 and y + 8 > my then
        knob_selected = true
        play = false
    elseif mx > 0 and width > mx and my > y - 8 and y + 8 > my then
        local px_d = stats_len / (width - 32)
        local dx = mx - x -- mouse from knob

        fake_index = math.min(math.max(fake_index + px_d * dx, 1), stats_len)

        knob_selected = true
        play = false
    end

    print(value_to_see)
end

function points:mousereleased(x, y, button)
    knob_selected = false
end

function points:mousemoved(x, y, dx, dy)
    if knob_selected then
        local px_d = stats_len / (width - 32)

        fake_index = math.min(math.max(fake_index + px_d * dx, 1), stats_len)
    end
end

function points:resize(w, h)
    width = w
    height = h
    updateSize()
end

function points:draw()
    if not stats then return end

    local highest = 0
    for i = start_index, index do
        for name, user in pairs(stats[i].positions) do
            if user[value_to_see] > highest then highest = user[value_to_see] end
        end
    end

    local pre_highest = 0
    for i = math.max(start_index - 1, 1), math.min(index - 1, stats_len) do
        for name, user in pairs(stats[i].positions) do
            if user[value_to_see] > pre_highest then pre_highest = user[value_to_see] end
        end
    end

    if animate and play then
        highest = linear(cooldown, pre_highest, highest - pre_highest, 1 / days_per_secs)
    end

    for i = math.max(start_index - 1, 1), math.min(index + 1, stats_len) do
        local x = (i - start_index) * days_size

        if animate and play and start_index > 1 then
            local pre_x = x - days_size
            x = linear(cooldown, x, pre_x - x, 1 / days_per_secs)
        end

        for name, user in spairs(stats[i].positions, function(t,a,b) return t[b][value_to_see] < t[a][value_to_see] end) do
            local value = user[value_to_see]
            local per = value / (highest + 100)
            local pos = user.pos
            local y = per * (-display_height) + display_height + top

            love.graphics.setColor(colors[name])
            local pre
            if stats[i - 1] ~= nil then
                pre = stats[i - 1].positions[name]
            end
            
            if pre then
                local pre_value = pre[value_to_see]
                local pre_per = pre_value / (highest + 100)
                local pre_y = pre_per * (-display_height) + display_height + top
                local pre_x = x - days_size

                if mode == "points" then
                    -- mode points
                    love.graphics.line(pre_x, pre_y, x, y)
                elseif mode == "smooth" then
                    -- mode smooth
                    love.graphics.polygon("fill", pre_x, display_height, pre_x, pre_y, x, y, x, display_height)
                end
            end

            if mode == "points" then
                -- mode points
                love.graphics.circle("fill", x, y, days_size / 20)
            elseif mode == "bars" then
                -- mode bars
                love.graphics.rectangle("fill", x - days_size / 2, y, days_size, display_height - y)
            end
        end

        -- display dates
        love.graphics.setColor(1, 1, 1)
        date_str:set(stats[i].date)
        love.graphics.draw(date_str, x - date_str:getWidth() / 2, display_height + top)

        -- draw date bars, vertical bars
        if days_size >= 32 then
            love.graphics.setColor(1, 1, 1, .25)
            x = math.min(x, display_width)
            love.graphics.line(x, top, x, display_height + top)
        end
    end

    love.graphics.setColor(love.graphics.getBackgroundColor())
    love.graphics.rectangle("fill", display_width, 0, width - display_width, height)
    
    -- draw avatars
    for name, user in spairs(stats[index].positions, function(t,a,b) return t[b][value_to_see] > t[a][value_to_see] end) do
        local value = user[value_to_see]
        local per = value / highest

        if animate and play and stats[index - 1] ~= nil then
            local pre = stats[index - 1].positions[name]
            
            if pre then
                local pre_per = pre[value_to_see] / pre_highest
                per = linear(cooldown, pre_per, per - pre_per, 1 / days_per_secs)
            end
        end

        local y = per * (-display_height) + display_height - days_size / 2 + top
        y = math.min(math.max(y, 0), display_height - days_size + top)
        local x = display_width

        love.graphics.setColor(colors[name])
        if avatars[name] then
            love.graphics.setColor(1, 1, 1)
            local w, h = avatars[name]:getDimensions()
            love.graphics.draw(avatars[name], x, y, 0, days_size / w, days_size / h)
        else
            love.graphics.rectangle("fill", x, y, days_size, days_size)
        end
    end

    -- draw progress bar
    local x = index / stats_len * (width - 32)
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
    love.graphics.rectangle("fill", 0, height - 48, width, 48) -- background

    love.graphics.setColor(1, 1, 1)
    love.graphics.line(16, height - 16, width - 16, height - 16)
    love.graphics.circle("fill", x + 16, height - 16, 8)

    local play_time = string.format("%02d:%02d/%02d:%02d", played_minutes, played_seconds, total_minutes, total_seconds)
    love.graphics.print(play_time, 16, height - 32)

    -- draw unit bars
    love.graphics.setColor(1, 1, 1, .5)
    for i = 0, unit_precision do
        local y = i * precision_size + top
        love.graphics.line(0, y, display_width, y) -- horizontal

        if i == 0 then
            unit_text:set(round(highest))
        else
            unit_text:set(round(highest * (1 - i / unit_precision)))
        end

        love.graphics.draw(unit_text, 0, math.min(y, display_height  - unit_text:getHeight() + top)) -- text
    end
end

return points