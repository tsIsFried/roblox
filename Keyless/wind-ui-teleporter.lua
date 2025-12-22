--[[
    ⚡ WIND UI KEYCAP TELEPORTER ⚡
    Enhanced teleporter with modern Wind UI interface
    Features: Auto-scan, smart pathfinding, advanced controls
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Wind UI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Wind-Scripts/Wind-UI/main/source.lua"))()

-- Configuration
local config = {
    teleportDelay = 0,            -- Delay between teleports (seconds)
    teleportHeight = 2,           -- Height above keycap
    sortByDistance = true,        -- Smart pathfinding
    loopTeleport = false,         -- Continuous loop
    showNotifications = true,     -- UI notifications
    tweenSpeed = 0,               -- Smooth teleport (0 = instant)
    autoScanOnStart = true,       -- Auto-scan on load
    skipCollected = true,         -- Skip already collected keycaps
    batchSize = 50,               -- Process in batches for performance
}

-- State management
local state = {
    keycaps = {},
    isTeleporting = false,
    isPaused = false,
    scanCompleted = false,
    totalCollected = 0,
    currentIndex = 0,
    startTime = 0,
}

-- Statistics
local stats = {
    totalFound = 0,
    totalTeleported = 0,
    timeElapsed = 0,
    keycapsPerSecond = 0,
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
    if not keycap or not keycap:IsDescendantOf(workspace) then
        return false
    end
    
    if not keycap:IsA("BasePart") then
        return false
    end
    
    -- Check if already collected (optional custom logic)
    if config.skipCollected and keycap:FindFirstChild("Collected") then
        return false
    end
    
    return true
end

-- ================================================
-- SCANNING FUNCTIONS
-- ================================================

local function scanKeycaps()
    state.keycaps = {}
    state.scanCompleted = false
    
    local keycapsFolder = workspace:FindFirstChild("keycaps")
    if not keycapsFolder then
        notify("❌ Error", "Keycaps folder not found!", 3)
        return {}
    end
    
    -- Recursive scan function
    local function recursiveScan(folder)
        for _, item in pairs(folder:GetChildren()) do
            if item:IsA("BasePart") then
                if isKeycapValid(item) then
                    table.insert(state.keycaps, item)
                end
            elseif item:IsA("Folder") or item:IsA("Model") then
                recursiveScan(item)
            end
        end
    end
    
    recursiveScan(keycapsFolder)
    
    -- Sort by proximity for shortest path
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

local function rescanKeycaps()
    notify("🔍 Scanning", "Rescanning keycaps...", 1)
    return scanKeycaps()
end

-- ================================================
-- TELEPORTATION FUNCTIONS
-- ================================================

local function teleportToPosition(position)
    if config.tweenSpeed > 0 then
        -- Smooth tween teleport
        local tweenInfo = TweenInfo.new(
            config.tweenSpeed,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )
        
        local tween = TweenService:Create(
            humanoidRootPart,
            tweenInfo,
            {CFrame = CFrame.new(position)}
        )
        
        tween:Play()
        tween.Completed:Wait()
    else
        -- Instant teleport
        humanoidRootPart.CFrame = CFrame.new(position)
    end
end

local function teleportToKeycap(keycap, index)
    if not isKeycapValid(keycap) then
        return false
    end
    
    local teleportPos = keycap.Position + Vector3.new(
        0,
        keycap.Size.Y / 2 + config.teleportHeight,
        0
    )
    
    teleportToPosition(teleportPos)
    
    state.currentIndex = index
    stats.totalTeleported = stats.totalTeleported + 1
    
    return true
end

local function startTeleportSequence()
    if state.isTeleporting then
        notify("⚠️ Warning", "Already teleporting!", 2)
        return
    end
    
    if #state.keycaps == 0 then
        notify("⚠️ Warning", "No keycaps found. Scan first!", 2)
        return
    end
    
    state.isTeleporting = true
    state.isPaused = false
    state.startTime = tick()
    stats.totalTeleported = 0
    
    notify("⚡ Starting", "Teleporting to " .. #state.keycaps .. " keycaps...", 2)
    
    task.spawn(function()
        repeat
            for i = 1, #state.keycaps do
                if not state.isTeleporting then break end
                
                -- Check for pause
                while state.isPaused and state.isTeleporting do
                    task.wait(0.1)
                end
                
                if not state.isTeleporting then break end
                
                local keycap = state.keycaps[i]
                
                if teleportToKeycap(keycap, i) then
                    -- Small delay between teleports
                    if config.teleportDelay > 0 and i < #state.keycaps then
                        task.wait(config.teleportDelay)
                    end
                end
                
                -- Update stats
                stats.timeElapsed = tick() - state.startTime
                if stats.timeElapsed > 0 then
                    stats.keycapsPerSecond = stats.totalTeleported / stats.timeElapsed
                end
            end
            
            if config.loopTeleport and state.isTeleporting then
                notify("🔄 Looping", "Starting next cycle...", 1)
                task.wait(1)
            end
        until not config.loopTeleport or not state.isTeleporting
        
        state.isTeleporting = false
        state.currentIndex = 0
        
        notify(
            "✅ Complete",
            string.format("Teleported to %d keycaps in %s", 
                stats.totalTeleported, 
                formatTime(stats.timeElapsed)
            ),
            3
        )
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
    
    if state.isPaused then
        notify("⏸️ Paused", "Teleportation paused", 2)
    else
        notify("▶️ Resumed", "Teleportation resumed", 2)
    end
end

-- ================================================
-- WIND UI INTERFACE
-- ================================================

local window = WindUI:CreateWindow({
    Title = "⚡ Keycap Teleporter",
    Icon = "rbxassetid://4483345998",
    Author = "Enhanced Edition",
    Folder = "KeycapTeleporter",
    Size = UDim2.fromOffset(500, 600),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Transparent = false,
    Theme = "Dark",
    SideBarWidth = 170,
})

-- ================================================
-- MAIN TAB
-- ================================================

local mainTab = window:Tab({
    Text = "Main",
    Icon = "rbxassetid://10734950309"
})

local controlSection = mainTab:Section({
    Text = "Teleport Controls"
})

controlSection:Label({
    Text = "Quick Actions",
    Flag = "Label1"
})

controlSection:Button({
    Text = "⚡ Start Teleport",
    Callback = function()
        startTeleportSequence()
    end
})

controlSection:Button({
    Text = "⏹️ Stop Teleport",
    Callback = function()
        stopTeleportSequence()
    end
})

controlSection:Button({
    Text = "⏸️ Pause/Resume",
    Callback = function()
        pauseTeleportSequence()
    end
})

controlSection:Divider()

local scanSection = mainTab:Section({
    Text = "Scanning"
})

scanSection:Button({
    Text = "🔍 Scan for Keycaps",
    Callback = function()
        scanKeycaps()
    end
})

scanSection:Button({
    Text = "🔄 Rescan Area",
    Callback = function()
        rescanKeycaps()
    end
})

-- Statistics Display
local statsSection = mainTab:Section({
    Text = "Statistics"
})

local statusLabel = statsSection:Label({
    Text = "Status: Ready",
    Flag = "StatusLabel"
})

local keycapCountLabel = statsSection:Label({
    Text = "Keycaps Found: 0",
    Flag = "KeycapCountLabel"
})

local progressLabel = statsSection:Label({
    Text = "Progress: 0/0",
    Flag = "ProgressLabel"
})

local timeLabel = statsSection:Label({
    Text = "Time: 00:00",
    Flag = "TimeLabel"
})

local speedLabel = statsSection:Label({
    Text = "Speed: 0/s",
    Flag = "SpeedLabel"
})

-- ================================================
-- SETTINGS TAB
-- ================================================

local settingsTab = window:Tab({
    Text = "Settings",
    Icon = "rbxassetid://10734949856"
})

local teleportSettings = settingsTab:Section({
    Text = "Teleport Settings"
})

teleportSettings:Slider({
    Text = "Teleport Delay",
    Min = 0,
    Max = 2,
    Default = config.teleportDelay,
    Callback = function(value)
        config.teleportDelay = value
    end,
    Increment = 0.05
})

teleportSettings:Slider({
    Text = "Teleport Height",
    Min = 0,
    Max = 10,
    Default = config.teleportHeight,
    Callback = function(value)
        config.teleportHeight = value
    end,
    Increment = 0.5
})

teleportSettings:Slider({
    Text = "Tween Speed",
    Min = 0,
    Max = 1,
    Default = config.tweenSpeed,
    Callback = function(value)
        config.tweenSpeed = value
    end,
    Increment = 0.05
})

teleportSettings:Toggle({
    Text = "Loop Teleport",
    Default = config.loopTeleport,
    Callback = function(value)
        config.loopTeleport = value
    end
})

teleportSettings:Toggle({
    Text = "Sort by Distance",
    Default = config.sortByDistance,
    Callback = function(value)
        config.sortByDistance = value
    end
})

teleportSettings:Toggle({
    Text = "Skip Collected",
    Default = config.skipCollected,
    Callback = function(value)
        config.skipCollected = value
    end
})

local uiSettings = settingsTab:Section({
    Text = "UI Settings"
})

uiSettings:Toggle({
    Text = "Show Notifications",
    Default = config.showNotifications,
    Callback = function(value)
        config.showNotifications = value
    end
})

uiSettings:Toggle({
    Text = "Auto-Scan on Start",
    Default = config.autoScanOnStart,
    Callback = function(value)
        config.autoScanOnStart = value
    end
})

-- ================================================
-- HOTKEYS TAB
-- ================================================

local hotkeysTab = window:Tab({
    Text = "Hotkeys",
    Icon = "rbxassetid://10747372992"
})

local hotkeysSection = hotkeysTab:Section({
    Text = "Keyboard Shortcuts"
})

hotkeysSection:Label({
    Text = "Configure keyboard shortcuts",
    Flag = "HotkeysLabel"
})

hotkeysSection:Keybind({
    Text = "Start/Stop Teleport",
    Default = Enum.KeyCode.T,
    Callback = function()
        if state.isTeleporting then
            stopTeleportSequence()
        else
            startTeleportSequence()
        end
    end
})

hotkeysSection:Keybind({
    Text = "Pause/Resume",
    Default = Enum.KeyCode.P,
    Callback = function()
        pauseTeleportSequence()
    end
})

hotkeysSection:Keybind({
    Text = "Scan Keycaps",
    Default = Enum.KeyCode.R,
    Callback = function()
        scanKeycaps()
    end
})

-- ================================================
-- INFO TAB
-- ================================================

local infoTab = window:Tab({
    Text = "Info",
    Icon = "rbxassetid://10747323693"
})

local infoSection = infoTab:Section({
    Text = "About"
})

infoSection:Label({
    Text = "⚡ Keycap Teleporter v2.0",
    Flag = "VersionLabel"
})

infoSection:Label({
    Text = "Enhanced with Wind UI",
    Flag = "UILabel"
})

infoSection:Divider()

local instructionsSection = infoTab:Section({
    Text = "How to Use"
})

instructionsSection:Label({
    Text = "1. Click 'Scan for Keycaps' to find all keycaps",
    Flag = "Instruction1"
})

instructionsSection:Label({
    Text = "2. Click 'Start Teleport' to begin collection",
    Flag = "Instruction2"
})

instructionsSection:Label({
    Text = "3. Use hotkeys for quick control (T = Start/Stop)",
    Flag = "Instruction3"
})

instructionsSection:Label({
    Text = "4. Adjust settings in the Settings tab",
    Flag = "Instruction4"
})

instructionsSection:Divider()

local featuresSection = infoTab:Section({
    Text = "Features"
})

featuresSection:Label({
    Text = "✅ Smart pathfinding (shortest route)",
    Flag = "Feature1"
})

featuresSection:Label({
    Text = "✅ Real-time statistics",
    Flag = "Feature2"
})

featuresSection:Label({
    Text = "✅ Pause/Resume functionality",
    Flag = "Feature3"
})

featuresSection:Label({
    Text = "✅ Loop mode for continuous farming",
    Flag = "Feature4"
})

featuresSection:Label({
    Text = "✅ Customizable teleport settings",
    Flag = "Feature5"
})

-- ================================================
-- REAL-TIME UI UPDATES
-- ================================================

task.spawn(function()
    while task.wait(0.5) do
        -- Update status
        if state.isTeleporting then
            if state.isPaused then
                statusLabel:Set({Text = "Status: ⏸️ Paused"})
            else
                statusLabel:Set({Text = "Status: ⚡ Teleporting..."})
            end
        else
            statusLabel:Set({Text = "Status: ✅ Ready"})
        end
        
        -- Update keycap count
        keycapCountLabel:Set({
            Text = string.format("Keycaps Found: %d", stats.totalFound)
        })
        
        -- Update progress
        if state.isTeleporting then
            progressLabel:Set({
                Text = string.format("Progress: %d/%d", state.currentIndex, #state.keycaps)
            })
        else
            progressLabel:Set({
                Text = string.format("Progress: 0/%d", #state.keycaps)
            })
        end
        
        -- Update time
        if state.isTeleporting then
            stats.timeElapsed = tick() - state.startTime
            timeLabel:Set({
                Text = "Time: " .. formatTime(stats.timeElapsed)
            })
        else
            timeLabel:Set({Text = "Time: 00:00"})
        end
        
        -- Update speed
        if stats.keycapsPerSecond > 0 then
            speedLabel:Set({
                Text = string.format("Speed: %.1f/s", stats.keycapsPerSecond)
            })
        else
            speedLabel:Set({Text = "Speed: 0/s"})
        end
    end
end)

-- ================================================
-- AUTO-SCAN ON START
-- ================================================

if config.autoScanOnStart then
    task.spawn(function()
        task.wait(2)
        notify("🔍 Auto-Scan", "Scanning for keycaps...", 2)
        scanKeycaps()
    end)
end

-- ================================================
-- CONSOLE OUTPUT
-- ================================================

print("======================================")
print("⚡ KEYCAP TELEPORTER v2.0 ⚡")
print("Enhanced with Wind UI")
print("======================================")
print("")
print("📌 HOW TO USE:")
print("1. Open the UI (should appear automatically)")
print("2. Click 'Scan for Keycaps' to find keycaps")
print("3. Click 'Start Teleport' to begin")
print("4. Use T key to quick start/stop")
print("")
print("✅ Script loaded successfully!")
print("======================================")
