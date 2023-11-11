MEH_MODS = { "ctrl", "alt", "shift" }

-- UTIL FUNCTIONS
function clamp(n, min, max)
    return math.min(math.max(n, min), max)
end

function round(n)
    local up = math.ceil(n)
    local down = math.floor(n)

    if (n - down) < (up - n) then
        return down
    else
        return up
    end
end

-- MODES
CurrentMode = nil

function switchMode(newMode)
    if CurrentMode ~= nil then
        for _, hotkey in pairs(CurrentMode.hotkeys) do
            hotkey:disable()
        end

        if CurrentMode["exit"] ~= nil then
            CurrentMode:exit()
        end
    end

    CurrentMode = newMode

    for _, hotkey in pairs(CurrentMode.hotkeys) do
        hotkey:enable()
    end

    if CurrentMode["enter"] ~= nil then
        CurrentMode:enter()
    end
end

function bind(self, mods, key, pressedfn)
    self.hotkeys[#self.hotkeys + 1] = hs.hotkey.new(mods, key, pressedfn)
end

Modes = {
    global = {
        hotkeys = {},
        wDivisions = 8,
        hDivisions = 8,
        init = function(self)
            -- Make window fill the left half of the monitor
            bind(self, MEH_MODS, "a", function()
                local win = hs.window.focusedWindow()
                local f = win:frame()
                local screen = win:screen()
                local max = screen:frame()

                f.x = max.x
                f.y = max.y
                f.w = max.w / 2
                f.h = max.h
                win:setFrame(f)
            end)

            -- Make window fill the right half of the monitor
            bind(self, MEH_MODS, "b", function()
                local win = hs.window.focusedWindow()
                local f = win:frame()
                local screen = win:screen()
                local max = screen:frame()

                f.x = max.x + (max.w / 2)
                f.y = max.y
                f.w = max.w / 2
                f.h = max.h
                win:setFrame(f)
            end)

            -- Make window fill the monitor
            bind(self, MEH_MODS, "f", function()
                local win = hs.window.focusedWindow()
                local f = win:frame()
                local screen = win:screen()
                local max = screen:frame()

                f.x = max.x
                f.y = max.y
                f.w = max.w
                f.h = max.h
                win:setFrame(f)
            end)

            -- Make window small (25% of monitor)
            bind(self, MEH_MODS, "s", function()
                local win = hs.window.focusedWindow()
                local f = win:frame()
                local screen = win:screen()
                local max = screen:frame()

                local center_x = (f.x + f.x + f.w) / 2
                local center_y = (f.y + f.y + f.h) / 2

                local new_width = max.w / 2
                local new_height = max.h / 2

                local new_x = clamp((center_x - (new_width / 2)), max.x, max.x + max.w - new_width)
                local new_y = clamp((center_y - (new_height / 2)), max.y, max.y + max.h - new_height)

                f.x = new_x
                f.y = new_y
                f.w = new_width
                f.h = new_height
                win:setFrame(f)
            end)

            -- Center window
            bind(self, MEH_MODS, "c", function()
                local win = hs.window.focusedWindow()
                local f = win:frame()
                local screen = win:screen()
                local max = screen:frame()

                f.x = max.x + (max.w / 2) - (f.w / 2)
                f.y = max.y + (max.h / 2) - (f.h / 2)
                win:setFrame(f)
            end)

            -- Move window to next monitor
            bind(self, MEH_MODS, "m", function()
                local win = hs.window.focusedWindow()
                local screen = win:screen()

                win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
            end)

            -- Resize windows with HJKL
            bind(self, MEH_MODS, "h", function() self:transformWindowRelative(0, 0, -1, 0) end)
            bind(self, MEH_MODS, "j", function() self:transformWindowRelative(0, 0, 0, 1) end)
            bind(self, MEH_MODS, "k", function() self:transformWindowRelative(0, 0, 0, -1) end)
            bind(self, MEH_MODS, "l", function() self:transformWindowRelative(0, 0, 1, 0) end)

            -- Move windows with arrow keys
            bind(self, MEH_MODS, "left", function() self:transformWindowRelative(-1, 0, 0, 0) end)
            bind(self, MEH_MODS, "down", function() self:transformWindowRelative(0, 1, 0, 0) end)
            bind(self, MEH_MODS, "up", function() self:transformWindowRelative(0, -1, 0, 0) end)
            bind(self, MEH_MODS, "right", function() self:transformWindowRelative(1, 0, 0, 0) end)

            -- Cycle through applications in space with ctrl+option+left/right
            bind(self, { "ctrl", "alt" }, "left", function() self:focusApp(-1) end)
            bind(self, { "ctrl", "alt" }, "right", function() self:focusApp(1) end)

            -- Pasteboard Interactions
            -- bind(self, MEH_MODS, "p", function()
            --     pb_text = hs.pasteboard.readString()
            --     hs.alert.show("Formatting removed")
            --     hs.pasteboard.setContents(pb_text)
            -- end)

            -- Mode Switching
            -- bind(self, MEH_MODS, "q", function() switchMode(Modes.quadClick) end)
            -- bind(self, MEH_MODS, "p", function() switchMode(Modes.screenshot) end)
        end,
        transformWindowRelative = function(self, x, y, w, h)
            local win = hs.window.focusedWindow()
            local f = win:frame()

            local center_x = (f.x + f.x + f.w) / 2
            local center_y = (f.y + f.y + f.h) / 2

            local max = win:screen():frame()
            local width_unit = max.w / self.wDivisions
            local height_unit = max.h / self.hDivisions

            local new_columns = clamp(round(f.w / width_unit) + w, 1, self.wDivisions)
            local new_rows = clamp(round(f.h / height_unit) + h, 1, self.hDivisions)
            local new_width = new_columns * width_unit
            local new_height = new_rows * height_unit

            local new_x = clamp((center_x - (new_width / 2)) + (x * width_unit), max.x, max.x + max.w - new_width)
            local new_y = clamp((center_y - (new_height / 2)) + (y * height_unit), max.y, max.y + max.h - new_height)

            f.w = new_width
            f.h = new_height
            f.x = new_x
            f.y = new_y
            win:setFrame(f)
        end,
        focusApp = function(self, offset)
            local current_window = hs.window.focusedWindow()
            local current_bundle_id = current_window:application():bundleID()

            local current_screen = current_window:screen()
            -- local current_screen_frame = current_screen:frame()
            local current_screen_id = current_screen:id()

            -- local sortByPosition = function(a, b)
            --     local frameA = a:frame()
            --     local frameB = b:frame()
            --
            --     if frameA.y ~= frameB.y then
            --         return frameA.y < frameB.y
            --     elseif frameA.x ~= frameB.x then
            --         return frameA.x < frameB.x
            --     else
            --         return hs.window.filter.sortByCreated(a, b)
            --     end
            -- end

            local window_filter = hs.window.filter.new():setCurrentSpace(true):setScreens(current_screen_id)
            local windows = window_filter:getWindows(hs.window.filter.sortByCreated)

            -- for _, window in pairs(windows) do
            --     print(window:title())
            -- end
            -- print("")

            local current_index = 1
            while current_index <= #windows do
                if windows[current_index]:id() == current_window:id() then
                    break
                end
                current_index = current_index + 1
            end

            local new_index = current_index
            for _ = 1, #windows do
                new_index = new_index + offset
                if new_index == 0 then
                    new_index = #windows
                elseif new_index > #windows then
                    new_index = 1
                end

                local window = windows[new_index]

                local visible = window:isVisible()
                local different_bundle = window:application():bundleID() ~= current_bundle_id

                if visible and different_bundle then
                    break
                end
            end

            if new_index ~= current_index then
                windows[new_index]:focus()
            end
        end,
    },
    screenshot = {
        -- Work in progress
        hotkeys = {},
        canvas = nil,
        frame = { x = 0, y = 0, w = 0, h = 0 },
        speed = 1,
        init = function(self)
            bind(self, {}, "escape", function() switchMode(Modes.global) end)

            bind(self, MEH_MODS, "h", function() self:transformRelative(0, 0, -1, 0) end)
            bind(self, MEH_MODS, "j", function() self:transformRelative(0, 0, 0, 1) end)
            bind(self, MEH_MODS, "k", function() self:transformRelative(0, 0, 0, -1) end)
            bind(self, MEH_MODS, "l", function() self:transformRelative(0, 0, 1, 0) end)

            bind(self, MEH_MODS, "left", function() self:transformRelative(-1, 0, 0, 0) end)
            bind(self, MEH_MODS, "down", function() self:transformRelative(0, 1, 0, 0) end)
            bind(self, MEH_MODS, "up", function() self:transformRelative(0, -1, 0, 0) end)
            bind(self, MEH_MODS, "right", function() self:transformRelative(1, 0, 0, 0) end)
        end,
        enter = function(self)
            local screen = hs.screen.mainScreen()
            local f = screen:frame()

            self.speed = 256

            self.frame = { x = f.x, y = f.y, w = f.w, h = f.h }

            self.canvas = hs.canvas.new { x = f.x, y = f.y, h = f.h, w = f.w }
            self.canvas:show()
            self:updateCanvas()
        end,
        exit = function(self)
            self.canvas:delete()
            self.canvas = nil
        end,
        transformRelative = function(self, x, y, w, h)
            local canvasFrame = self.canvas:frame()

            self.frame = {
                x = clamp(self.frame.x + x * self.speed, canvasFrame.x, canvasFrame.x + canvasFrame.w - self.frame.w),
                y = clamp(self.frame.y + y * self.speed, canvasFrame.y, canvasFrame.y + canvasFrame.h - self.frame.h),
                w = clamp(self.frame.w + w * self.speed, 1, canvasFrame.w - (self.frame.x - canvasFrame.x)),
                h = clamp(self.frame.h + h * self.speed, 1, canvasFrame.h - (self.frame.y - canvasFrame.y)),
            }

            self:updateCanvas()
        end,
        updateCanvas = function(self)
            local canvasFrame = self.canvas:frame()

            self.canvas[1] = {
                type = "rectangle",
                frame = {
                    x = self.frame.x - canvasFrame.x - 1,
                    y = self.frame.y - canvasFrame.y - 1,
                    w = self.frame.w + 2,
                    h = self.frame.h + 2,
                },
                strokeColor = { red = 1, green = 1, blue = 1, alpha = 0.8 },
                strokeWidth = 1,
                action = "stroke"
            }
        end,
    },
    quadClick = {
        -- Work in progress
        hotkeys = {},
        canvas = nil,
        canvasOffset = { x = 0, y = 0 },
        frame = { x = 0, y = 0, w = 0, h = 0 },
        init = function(self)
            bind(self, {}, "escape", function() switchMode(Modes.global) end)
            bind(self, {}, "return", function() self:click() end)

            bind(self, MEH_MODS, "h", function() self:select(-1, 0) end)
            bind(self, MEH_MODS, "j", function() self:select(0, 1) end)
            bind(self, MEH_MODS, "k", function() self:select(0, -1) end)
            bind(self, MEH_MODS, "l", function() self:select(1, 0) end)
        end,
        enter = function(self)
            local screen = hs.screen.mainScreen()
            local f = screen:frame()

            self.frame = { x = f.x, y = f.y, w = f.w, h = f.h }
            self.canvasOffset = { x = f.x, y = f.y }

            self.canvas = hs.canvas.new { x = f.x, y = f.y, h = f.h, w = f.w }
            self.canvas:show()
            self:updateCanvas()
        end,
        exit = function(self)
            self.canvas:delete()
            self.canvas = nil
        end,
        click = function(self)
            hs.eventtap.leftClick({
                x = self.frame.x + (self.frame.w / 2),
                y = self.frame.y + (self.frame.h / 2),
            })

            switchMode(Modes.global)
        end,
        select = function(self, x, y)
            if x ~= 0 then
                local halfW = self.frame.w / 2

                local newX = self.frame.x
                if x > 0 then
                    newX = newX + halfW
                end

                self.frame = {
                    x = newX,
                    y = self.frame.y,
                    w = halfW,
                    h = self.frame.h,
                }
            else
                local halfH = self.frame.h / 2

                local newY = self.frame.y
                if y > 0 then
                    newY = newY + halfH
                end

                self.frame = {
                    x = self.frame.x,
                    y = newY,
                    w = self.frame.w,
                    h = halfH,
                }
            end

            self:updateCanvas()
        end,
        updateCanvas = function(self)
            self.canvas[1] = {
                type = "rectangle",
                frame = {
                    x = (self.frame.x - self.canvasOffset.x) + 2,
                    y = (self.frame.y - self.canvasOffset.y) + 2,
                    w = self.frame.w - 4,
                    h = self.frame.h - 4,
                },
                strokeColor = { red = 1, green = 1, blue = 1, alpha = 0.8 },
                strokeWidth = 1,
                action = "stroke"
            }

            self.canvas[2] = {
                type = "rectangle",
                frame = {
                    x = (self.frame.x - self.canvasOffset.x) + (self.frame.w / 2) - 2,
                    y = (self.frame.y - self.canvasOffset.y) + (self.frame.h / 2) - 2,
                    w = 4,
                    h = 4,
                },
                fillColor = { red = 1, green = 0.1, blue = 0.1, alpha = 0.8 },
                action = "fill"
            }
        end,
    },
}

for _, mode in pairs(Modes) do
    if mode["init"] ~= nil then
        mode:init()
    end
end

switchMode(Modes.global)

hs.hotkey.bind(MEH_MODS, "escape", function()
    switchMode(Modes.global)
end)

-- HAMMERSPOON
hs.hotkey.bind(MEH_MODS, "r", function()
    hs.reload()
end)
hs.alert.show("Config loaded")
