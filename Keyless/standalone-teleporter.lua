--[[
    ⚡ STANDALONE KEYCAP TELEPORTER ⚡
    Enhanced teleporter with custom modern UI (no external dependencies)
    Features: Auto-scan, smart pathfinding, advanced controls
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local config = {
    teleportDelay = 0,
    teleportHeight = 2,
    sortByDistance = true,
    loopTeleport = false,
    showNotifications = true,
    tweenSpeed = 0,
    autoScanOnStart = true,
    theme = {
        primary = Color3.fromRGB(88, 101, 242),
        secondary = Color3.fromRGB(32, 34, 37),
        background = Color3.fromRGB(47, 49, 54),
        success = Color3.fromRGB(67, 181, 129),
        danger = Color3.fromRGB(237, 66, 69),
        warning = Color3.fromRGB(250, 166, 26),
        text = Color3.fromRGB(255, 255, 255),
        textDark = Color3.fromRGB(185, 187, 190),
    }
}

-- State
local state = {
    keycaps = {},
    isTeleporting = false,
    isPaused = false,
    scanCompleted = false,
    currentIndex = 0,
    startTime = 0,
}

-- Stats
local stats = {
    totalFound = 0,
    totalTeleported = 0,
    timeElapsed = 0,
}

-- ================================================
-- UTILITY FUNCTIONS
-- ================================================

local function notify(title, message, duration)
    if not config.showNotifications then return end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 3,
            Icon = "rbxassetid://4483345998"
        })
    end)
end

local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

local function isKeycapValid(keycap)
    return keycap and keycap:IsDescendantOf(workspace) and keycap:IsA("BasePart")
end

-- ================================================
-- MODERN UI CREATION
-- ================================================

local UI = {}

function UI.createRoundedFrame(parent, props)
    local frame = Instance.new("Frame")
    frame.Size = props.Size or UDim2.fromScale(1, 1)
    frame.Position = props.Position or UDim2.fromScale(0, 0)
    frame.BackgroundColor3 = props.BackgroundColor or config.theme.background
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.CornerRadius or 8)
    corner.Parent = frame
    
    if props.Shadow then
        local shadow = Instance.new("ImageLabel")
        shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 0.7
        shadow.Size = UDim2.fromScale(1, 1)
        shadow.Position = UDim2.fromOffset(0, 4)
        shadow.BackgroundTransparency = 1
        shadow.ZIndex = frame.ZIndex - 1
        shadow.Parent = frame
    end
    
    return frame
end

function UI.createButton(parent, props)
    local button = Instance.new("TextButton")
    button.Size = props.Size or UDim2.new(1, -20, 0, 36)
    button.Position = props.Position or UDim2.fromOffset(10, 10)
    button.BackgroundColor3 = props.BackgroundColor or config.theme.primary
    button.BorderSizePixel = 0
    button.Text = props.Text or "Button"
    button.TextColor3 = config.theme.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, props.BackgroundColor.R * 255 + 20),
                math.min(255, props.BackgroundColor.G * 255 + 20),
                math.min(255, props.BackgroundColor.B * 255 + 20)
            )
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = props.BackgroundColor or config.theme.primary
        }):Play()
    end)
    
    if props.Callback then
        button.MouseButton1Click:Connect(props.Callback)
    end
    
    return button
end

function UI.createLabel(parent, props)
    local label = Instance.new("TextLabel")
    label.Size = props.Size or UDim2.new(1, -20, 0, 20)
    label.Position = props.Position or UDim2.fromOffset(10, 10)
    label.BackgroundTransparency = 1
    label.Text = props.Text or "Label"
    label.TextColor3 = props.TextColor or config.theme.text
    label.Font = Enum.Font.Gotham
    label.TextSize = props.TextSize or 14
    label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    label.Parent = parent
    
    return label
end

function UI.createSlider(parent, props)
    local container = Instance.new("Frame")
    container.Size = props.Size or UDim2.new(1, -20, 0, 50)
    container.Position = props.Position or UDim2.fromOffset(10, 10)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = UI.createLabel(container, {
        Text = props.Text or "Slider",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.fromOffset(0, 0)
    })
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, 0, 0, 6)
    sliderBack.Position = UDim2.new(0, 0, 0, 30)
    sliderBack.BackgroundColor3 = config.theme.secondary
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderBack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.fromScale(0.5, 1)
    sliderFill.BackgroundColor3 = config.theme.primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local valueLabel = UI.createLabel(container, {
        Text = tostring(props.Default or 0),
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -50, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor = config.theme.textDark
    })
    
    local dragging = false
    local min = props.Min or 0
    local max = props.Max or 100
    local current = props.Default or min
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        current = min + (max - min) * pos
        
        if props.Increment then
            current = math.floor(current / props.Increment + 0.5) * props.Increment
        end
        
        sliderFill.Size = UDim2.fromScale((current - min) / (max - min), 1)
        valueLabel.Text = string.format("%.2f", current)
        
        if props.Callback then
            props.Callback(current)
        end
    end
    
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return container
end

function UI.createToggle(parent, props)
    local container = Instance.new("Frame")
    container.Size = props.Size or UDim2.new(1, -20, 0, 30)
    container.Position = props.Position or UDim2.fromOffset(10, 10)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = UI.createLabel(container, {
        Text = props.Text or "Toggle",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        TextSize = 13
    })
    
    local toggleBack = Instance.new("TextButton")
    toggleBack.Size = UDim2.fromOffset(40, 20)
    toggleBack.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBack.BackgroundColor3 = props.Default and config.theme.success or config.theme.secondary
    toggleBack.BorderSizePixel = 0
    toggleBack.Text = ""
    toggleBack.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBack
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.fromOffset(16, 16)
    toggleCircle.Position = props.Default and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
    toggleCircle.BackgroundColor3 = config.theme.text
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBack
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    local enabled = props.Default or false
    
    toggleBack.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        TweenService:Create(toggleBack, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and config.theme.success or config.theme.secondary
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
        }):Play()
        
        if props.Callback then
            props.Callback(enabled)
        end
    end)
    
    return container
end

-- ================================================
-- SCANNING & TELEPORTATION
-- ================================================

local function scanKeycaps()
    state.keycaps = {}
    
    local keycapsFolder = workspace:FindFirstChild("keycaps")
    if not keycapsFolder then
        notify("❌ Error", "Keycaps folder not found!", 3)
        return {}
    end
    
    local function recursiveScan(folder)
        for _, item in pairs(folder:GetChildren()) do
            if item:IsA("BasePart") and isKeycapValid(item) then
                table.insert(state.keycaps, item)
            elseif item:IsA("Folder") or item:IsA("Model") then
                recursiveScan(item)
            end
        end
    end
    
    recursiveScan(keycapsFolder)
    
    if config.sortByDistance and #state.keycaps > 1 then
        local sorted = {}
        local currentPos = humanoidRootPart.Position
        local remaining = {unpack(state.keycaps)}
        
        while #remaining > 0 do
            local nearestIndex = 1
            local nearestDist = (currentPos - remaining[1].Position).Magnitude
            
            for i = 2, #remaining do
                local dist = (currentPos - remaining[i].Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestIndex = i
                end
            end
            
            table.insert(sorted, remaining[nearestIndex])
            currentPos = remaining[nearestIndex].Position
            table.remove(remaining, nearestIndex)
        end
        
        state.keycaps = sorted
    end
    
    state.scanCompleted = true
    stats.totalFound = #state.keycaps
    
    notify("✅ Scan Complete", stats.totalFound .. " keycaps found!", 2)
    return state.keycaps
end

local function teleportToPosition(position)
    if config.tweenSpeed > 0 then
        local tween = TweenService:Create(
            humanoidRootPart,
            TweenInfo.new(config.tweenSpeed, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(position)}
        )
        tween:Play()
        tween.Completed:Wait()
    else
        humanoidRootPart.CFrame = CFrame.new(position)
    end
end

local function startTeleportSequence()
    if state.isTeleporting then return end
    if #state.keycaps == 0 then
        notify("⚠️ Warning", "No keycaps found. Scan first!", 2)
        return
    end
    
    state.isTeleporting = true
    state.startTime = tick()
    stats.totalTeleported = 0
    
    notify("⚡ Starting", "Teleporting to " .. #state.keycaps .. " keycaps...", 2)
    
    task.spawn(function()
        repeat
            for i = 1, #state.keycaps do
                if not state.isTeleporting then break end
                
                while state.isPaused and state.isTeleporting do
                    task.wait(0.1)
                end
                
                if not state.isTeleporting then break end
                
                local keycap = state.keycaps[i]
                if isKeycapValid(keycap) then
                    local pos = keycap.Position + Vector3.new(0, keycap.Size.Y / 2 + config.teleportHeight, 0)
                    teleportToPosition(pos)
                    state.currentIndex = i
                    stats.totalTeleported = stats.totalTeleported + 1
                    
                    if config.teleportDelay > 0 then
                        task.wait(config.teleportDelay)
                    end
                end
            end
            
            if config.loopTeleport and state.isTeleporting then
                task.wait(1)
            end
        until not config.loopTeleport or not state.isTeleporting
        
        state.isTeleporting = false
        stats.timeElapsed = tick() - state.startTime
        
        notify("✅ Complete", string.format("Teleported to %d keycaps in %s", 
            stats.totalTeleported, formatTime(stats.timeElapsed)), 3)
    end)
end

local function stopTeleportSequence()
    state.isTeleporting = false
    state.isPaused = false
    notify("⏹️ Stopped", "Teleportation stopped", 2)
end

local function pauseTeleportSequence()
    if not state.isTeleporting then return end
    state.isPaused = not state.isPaused
    notify(state.isPaused and "⏸️ Paused" or "▶️ Resumed", 
        state.isPaused and "Teleportation paused" or "Teleportation resumed", 2)
end

-- ================================================
-- CREATE MAIN UI
-- ================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernTeleporterUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = UI.createRoundedFrame(screenGui, {
    Size = UDim2.fromOffset(380, 520),
    Position = UDim2.new(0.5, -190, 0.5, -260),
    BackgroundColor = config.theme.background,
    CornerRadius = 12,
    Shadow = true
})

-- Make draggable
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = config.theme.secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleMask = Instance.new("Frame")
titleMask.Size = UDim2.new(1, 0, 0, 12)
titleMask.Position = UDim2.new(0, 0, 1, -12)
titleMask.BackgroundColor3 = config.theme.secondary
titleMask.BorderSizePixel = 0
titleMask.Parent = titleBar

local titleLabel = UI.createLabel(titleBar, {
    Text = "⚡ Keycap Teleporter v2.0",
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(15, 0),
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
})
titleLabel.Font = Enum.Font.GothamBold

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.new(1, -40, 0.5, -15)
closeButton.BackgroundColor3 = config.theme.danger
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = config.theme.text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Content area
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -70)
contentFrame.Position = UDim2.fromOffset(10, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.CanvasSize = UDim2.fromOffset(0, 800)
contentFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = contentFrame

-- Controls Section
local controlsTitle = UI.createLabel(contentFrame, {
    Text = "CONTROLS",
    Size = UDim2.new(1, 0, 0, 25),
    TextSize = 12,
    TextColor = config.theme.textDark,
    TextXAlignment = Enum.TextXAlignment.Left
})
controlsTitle.Font = Enum.Font.GothamBold

UI.createButton(contentFrame, {
    Text = "⚡ START TELEPORT",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor = config.theme.success,
    Callback = startTeleportSequence
})

local pauseButton = UI.createButton(contentFrame, {
    Text = "⏸️ PAUSE / RESUME",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor = config.theme.warning,
    Callback = pauseTeleportSequence
})

UI.createButton(contentFrame, {
    Text = "⏹️ STOP",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor = config.theme.danger,
    Callback = stopTeleportSequence
})

UI.createButton(contentFrame, {
    Text = "🔍 SCAN KEYCAPS",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor = config.theme.primary,
    Callback = scanKeycaps
})

-- Stats Section
local statsTitle = UI.createLabel(contentFrame, {
    Text = "STATISTICS",
    Size = UDim2.new(1, 0, 0, 25),
    TextSize = 12,
    TextColor = config.theme.textDark,
    TextXAlignment = Enum.TextXAlignment.Left
})
statsTitle.Font = Enum.Font.GothamBold

local statsLabels = {}
statsLabels.status = UI.createLabel(contentFrame, {
    Text = "Status: ✅ Ready",
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 13
})

statsLabels.found = UI.createLabel(contentFrame, {
    Text = "Keycaps Found: 0",
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 13
})

statsLabels.progress = UI.createLabel(contentFrame, {
    Text = "Progress: 0/0",
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 13
})

statsLabels.time = UI.createLabel(contentFrame, {
    Text = "Time: 00:00",
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 13
})

-- Settings Section
local settingsTitle = UI.createLabel(contentFrame, {
    Text = "SETTINGS",
    Size = UDim2.new(1, 0, 0, 25),
    TextSize = 12,
    TextColor = config.theme.textDark,
    TextXAlignment = Enum.TextXAlignment.Left
})
settingsTitle.Font = Enum.Font.GothamBold

UI.createSlider(contentFrame, {
    Text = "Teleport Delay (seconds)",
    Min = 0,
    Max = 2,
    Default = config.teleportDelay,
    Increment = 0.05,
    Callback = function(value)
        config.teleportDelay = value
    end
})

UI.createSlider(contentFrame, {
    Text = "Teleport Height",
    Min = 0,
    Max = 10,
    Default = config.teleportHeight,
    Increment = 0.5,
    Callback = function(value)
        config.teleportHeight = value
    end
})

UI.createToggle(contentFrame, {
    Text = "Loop Teleport",
    Default = config.loopTeleport,
    Callback = function(value)
        config.loopTeleport = value
    end
})

UI.createToggle(contentFrame, {
    Text = "Sort by Distance",
    Default = config.sortByDistance,
    Callback = function(value)
        config.sortByDistance = value
    end
})

UI.createToggle(contentFrame, {
    Text = "Show Notifications",
    Default = config.showNotifications,
    Callback = function(value)
        config.showNotifications = value
    end
})

-- Hotkeys info
local hotkeysTitle = UI.createLabel(contentFrame, {
    Text = "HOTKEYS",
    Size = UDim2.new(1, 0, 0, 25),
    TextSize = 12,
    TextColor = config.theme.textDark,
    TextXAlignment = Enum.TextXAlignment.Left
})
hotkeysTitle.Font = Enum.Font.GothamBold

UI.createLabel(contentFrame, {
    Text = "T - Start/Stop Teleport",
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 12,
    TextColor = config.theme.textDark
})

UI.createLabel(contentFrame, {
    Text = "P - Pause/Resume",
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 12,
    TextColor = config.theme.textDark
})

UI.createLabel(contentFrame, {
    Text = "R - Rescan Keycaps",
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 12,
    TextColor = config.theme.textDark
})

-- ================================================
-- HOTKEYS
-- ================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        if state.isTeleporting then
            stopTeleportSequence()
        else
            startTeleportSequence()
        end
    elseif input.KeyCode == Enum.KeyCode.P then
        pauseTeleportSequence()
    elseif input.KeyCode == Enum.KeyCode.R then
        scanKeycaps()
    end
end)

-- ================================================
-- REAL-TIME UPDATES
-- ================================================

task.spawn(function()
    while task.wait(0.5) do
        if state.isTeleporting then
            if state.isPaused then
                statsLabels.status.Text = "Status: ⏸️ Paused"
            else
                statsLabels.status.Text = "Status: ⚡ Teleporting..."
            end
            
            statsLabels.progress.Text = string.format("Progress: %d/%d", state.currentIndex, #state.keycaps)
            stats.timeElapsed = tick() - state.startTime
            statsLabels.time.Text = "Time: " .. formatTime(stats.timeElapsed)
        else
            statsLabels.status.Text = "Status: ✅ Ready"
            statsLabels.progress.Text = string.format("Progress: 0/%d", #state.keycaps)
            statsLabels.time.Text = "Time: 00:00"
        end
        
        statsLabels.found.Text = "Keycaps Found: " .. stats.totalFound
    end
end)

-- ================================================
-- AUTO-SCAN
-- ================================================

if config.autoScanOnStart then
    task.spawn(function()
        task.wait(2)
        notify("🔍 Auto-Scan", "Scanning for keycaps...", 2)
        scanKeycaps()
    end)
end

-- ================================================
-- INITIALIZATION
-- ================================================

print("======================================")
print("⚡ KEYCAP TELEPORTER v2.0 ⚡")
print("Standalone Edition")
print("======================================")
print("")
print("📌 HOW TO USE:")
print("1. Click 'SCAN KEYCAPS' to find keycaps")
print("2. Click 'START TELEPORT' to begin")
print("3. Use T/P/R keys for quick control")
print("")
print("✅ Script loaded successfully!")
print("======================================")
