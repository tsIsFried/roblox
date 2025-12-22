# ⚙️ Advanced Configuration Guide

Comprehensive guide to customizing your Keycap Teleporter.

## Table of Contents
1. [Basic Configuration](#basic-configuration)
2. [Advanced Settings](#advanced-settings)
3. [Theme Customization](#theme-customization)
4. [Performance Tuning](#performance-tuning)
5. [Custom Behaviors](#custom-behaviors)
6. [Troubleshooting Settings](#troubleshooting-settings)

---

## Basic Configuration

### Location in Code
Find the `config` table near the top of the script:

```lua
local config = {
    teleportDelay = 0,
    teleportHeight = 2,
    sortByDistance = true,
    loopTeleport = false,
    showNotifications = true,
    tweenSpeed = 0,
    autoScanOnStart = true,
    skipCollected = true,
    batchSize = 50,
}
```

### Core Settings

#### `teleportDelay` (number)
**Default:** `0`  
**Range:** `0` to `∞` seconds  
**Description:** Delay between each teleport

```lua
teleportDelay = 0      -- Instant (fastest, most detectable)
teleportDelay = 0.05   -- Very fast (good balance)
teleportDelay = 0.1    -- Fast (safer)
teleportDelay = 0.2    -- Moderate (safest)
teleportDelay = 0.5    -- Slow (very safe, obvious to observers)
```

**Use Cases:**
- `0` - Speed runs, testing
- `0.05-0.1` - Normal farming
- `0.2+` - AFK farming, maximum safety

---

#### `teleportHeight` (number)
**Default:** `2`  
**Range:** `0` to `20` studs  
**Description:** Height above keycap to teleport to

```lua
teleportHeight = 0     -- Directly on keycap (may clip into ground)
teleportHeight = 2     -- Standard (recommended)
teleportHeight = 5     -- High (for elevated keycaps)
teleportHeight = 10    -- Very high (for unusual layouts)
```

**Use Cases:**
- `0-1` - Flat surfaces
- `2-3` - Standard keycaps
- `4-6` - Elevated or large keycaps
- `7+` - Special cases, obstacles above keycaps

---

#### `sortByDistance` (boolean)
**Default:** `true`  
**Description:** Use smart pathfinding (shortest route)

```lua
sortByDistance = true   -- Smart pathfinding (recommended)
sortByDistance = false  -- Collect in discovery order
```

**Performance Impact:**
- `true` - Slight scan delay, much faster collection
- `false` - Instant scan, potentially longer collection

**When to disable:**
- Very small maps (< 10 keycaps)
- Testing/debugging
- Specific collection order required

---

#### `loopTeleport` (boolean)
**Default:** `false`  
**Description:** Restart automatically after completing

```lua
loopTeleport = false   -- Single run
loopTeleport = true    -- Continuous loop
```

**Use Cases:**
- `false` - One-time collection
- `true` - AFK farming, respawning keycaps

**⚠️ Warning:** Loop mode will continue indefinitely. Make sure to have a stop mechanism.

---

#### `showNotifications` (boolean)
**Default:** `true`  
**Description:** Display in-game notifications

```lua
showNotifications = true    -- Show notifications
showNotifications = false   -- Silent mode
```

**Use Cases:**
- `true` - Normal usage, monitoring progress
- `false` - Minimal UI, recording/streaming

---

#### `tweenSpeed` (number)
**Default:** `0`  
**Range:** `0` to `5` seconds  
**Description:** Smooth teleport animation duration

```lua
tweenSpeed = 0      -- Instant teleport
tweenSpeed = 0.1    -- Very fast smooth movement
tweenSpeed = 0.3    -- Fast smooth movement
tweenSpeed = 0.5    -- Moderate smooth movement
tweenSpeed = 1.0    -- Slow smooth movement
```

**Use Cases:**
- `0` - Maximum speed
- `0.1-0.3` - Natural-looking movement
- `0.5+` - Cinematic, demonstration

**Note:** Tween speed adds to total collection time.

---

#### `autoScanOnStart` (boolean)
**Default:** `true`  
**Description:** Automatically scan when script loads

```lua
autoScanOnStart = true    -- Auto-scan on load
autoScanOnStart = false   -- Manual scan required
```

**Use Cases:**
- `true` - Convenience, ready immediately
- `false` - Manual control, testing

---

## Advanced Settings

### Pathfinding Algorithm

Customize the smart pathfinding behavior:

```lua
-- In the scanKeycaps function, modify the sorting algorithm

-- Current: Nearest-neighbor greedy algorithm
-- Alternative 1: Simple distance sort (faster, less optimal)
table.sort(state.keycaps, function(a, b)
    return (a.Position - humanoidRootPart.Position).Magnitude <
           (b.Position - humanoidRootPart.Position).Magnitude
end)

-- Alternative 2: Clustered approach (for spread-out keycaps)
-- Group keycaps by region, then optimize within regions
```

### Validation Rules

Customize what counts as a valid keycap:

```lua
local function isKeycapValid(keycap)
    -- Standard checks
    if not keycap or not keycap:IsDescendantOf(workspace) then
        return false
    end
    
    if not keycap:IsA("BasePart") then
        return false
    end
    
    -- Add custom checks:
    
    -- Size filter (ignore very small/large parts)
    if keycap.Size.Magnitude < 1 or keycap.Size.Magnitude > 10 then
        return false
    end
    
    -- Transparency filter (ignore invisible keycaps)
    if keycap.Transparency > 0.9 then
        return false
    end
    
    -- Distance filter (ignore very far keycaps)
    local distance = (keycap.Position - humanoidRootPart.Position).Magnitude
    if distance > 5000 then
        return false
    end
    
    -- Color filter (only specific colors)
    -- if keycap.Color ~= Color3.fromRGB(255, 0, 0) then
    --     return false
    -- end
    
    return true
end
```

### Batch Processing

For large quantities, process in batches:

```lua
config.batchSize = 50  -- Process 50 keycaps before brief pause

-- In teleportation loop:
for i = 1, #state.keycaps do
    -- Teleport logic...
    
    -- Add batch pause
    if i % config.batchSize == 0 then
        task.wait(0.5)  -- Pause between batches
    end
end
```

---

## Theme Customization

### Standalone Version Only

Modify the theme colors in the `config.theme` table:

```lua
local config = {
    -- ... other settings ...
    theme = {
        primary = Color3.fromRGB(88, 101, 242),      -- Main accent color
        secondary = Color3.fromRGB(32, 34, 37),      -- Secondary background
        background = Color3.fromRGB(47, 49, 54),     -- Main background
        success = Color3.fromRGB(67, 181, 129),      -- Success buttons
        danger = Color3.fromRGB(237, 66, 69),        -- Danger/stop buttons
        warning = Color3.fromRGB(250, 166, 26),      -- Warning buttons
        text = Color3.fromRGB(255, 255, 255),        -- Primary text
        textDark = Color3.fromRGB(185, 187, 190),    -- Secondary text
    }
}
```

### Preset Themes

#### Dark Blue (Default)
```lua
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
```

#### Cyberpunk Purple
```lua
theme = {
    primary = Color3.fromRGB(139, 0, 255),
    secondary = Color3.fromRGB(20, 0, 40),
    background = Color3.fromRGB(30, 0, 60),
    success = Color3.fromRGB(0, 255, 200),
    danger = Color3.fromRGB(255, 0, 100),
    warning = Color3.fromRGB(255, 200, 0),
    text = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(180, 180, 220),
}
```

#### Forest Green
```lua
theme = {
    primary = Color3.fromRGB(34, 139, 34),
    secondary = Color3.fromRGB(20, 40, 20),
    background = Color3.fromRGB(30, 50, 30),
    success = Color3.fromRGB(50, 205, 50),
    danger = Color3.fromRGB(220, 20, 60),
    warning = Color3.fromRGB(255, 215, 0),
    text = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(200, 220, 200),
}
```

#### Ocean Blue
```lua
theme = {
    primary = Color3.fromRGB(0, 119, 182),
    secondary = Color3.fromRGB(15, 30, 45),
    background = Color3.fromRGB(20, 40, 60),
    success = Color3.fromRGB(0, 200, 200),
    danger = Color3.fromRGB(255, 80, 80),
    warning = Color3.fromRGB(255, 165, 0),
    text = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(180, 200, 220),
}
```

---

## Performance Tuning

### Maximum Speed Setup
```lua
config = {
    teleportDelay = 0,              -- No delay
    teleportHeight = 2,             -- Standard
    sortByDistance = true,          -- Shortest path
    loopTeleport = false,           -- Single run
    showNotifications = false,      -- No notifications
    tweenSpeed = 0,                 -- Instant
    autoScanOnStart = true,         -- Auto-scan
}
```

**Expected Performance:** 100-200 keycaps/second

---

### Balanced Setup
```lua
config = {
    teleportDelay = 0.05,           -- Very fast
    teleportHeight = 2,             -- Standard
    sortByDistance = true,          -- Shortest path
    loopTeleport = false,           -- Single run
    showNotifications = true,       -- Monitor progress
    tweenSpeed = 0,                 -- Instant
    autoScanOnStart = true,         -- Auto-scan
}
```

**Expected Performance:** 20-50 keycaps/second

---

### Maximum Safety Setup
```lua
config = {
    teleportDelay = 0.2,            -- Safe delay
    teleportHeight = 3,             -- Higher position
    sortByDistance = true,          -- Shortest path
    loopTeleport = false,           -- Single run
    showNotifications = true,       -- Monitor progress
    tweenSpeed = 0.1,               -- Slight smoothing
    autoScanOnStart = true,         -- Auto-scan
}
```

**Expected Performance:** 5-10 keycaps/second

---

### AFK Farming Setup
```lua
config = {
    teleportDelay = 0.1,            -- Moderate delay
    teleportHeight = 2,             -- Standard
    sortByDistance = true,          -- Shortest path
    loopTeleport = true,            -- Continuous loop
    showNotifications = true,       -- Monitor progress
    tweenSpeed = 0,                 -- Instant
    autoScanOnStart = true,         -- Auto-scan
}
```

---

## Custom Behaviors

### Keycap-Specific Actions

Execute custom code on each keycap:

```lua
-- In the teleportation loop, after teleporting:
local function onKeycapCollect(keycap, index)
    -- Log collection
    print(string.format("Collected #%d: %s", index, keycap.Name))
    
    -- Flash the keycap
    local originalColor = keycap.Color
    keycap.Color = Color3.fromRGB(0, 255, 0)
    task.wait(0.1)
    keycap.Color = originalColor
    
    -- Play sound
    -- local sound = Instance.new("Sound")
    -- sound.SoundId = "rbxassetid://12345"
    -- sound.Parent = keycap
    -- sound:Play()
    
    -- Custom statistics
    -- stats.totalValue = stats.totalValue + keycap:GetAttribute("Value")
end

-- Call in teleport function:
if teleportToKeycap(keycap, i) then
    onKeycapCollect(keycap, i)
    -- ... rest of code
end
```

### Conditional Teleportation

Skip certain keycaps based on conditions:

```lua
local function shouldCollectKeycap(keycap, index)
    -- Skip every other keycap
    -- if index % 2 == 0 then return false end
    
    -- Skip keycaps by name
    -- if keycap.Name:match("rare") then return false end
    
    -- Skip based on distance from spawn
    -- local spawnDistance = (keycap.Position - Vector3.new(0, 0, 0)).Magnitude
    -- if spawnDistance > 1000 then return false end
    
    -- Skip based on time
    -- if tick() - state.startTime > 300 then return false end
    
    return true
end

-- Use in teleportation loop:
if shouldCollectKeycap(keycap, i) and teleportToKeycap(keycap, i) then
    -- Collect
end
```

---

## Troubleshooting Settings

### Issue: Getting Kicked/Detected

**Solution:** Increase delays and add randomization

```lua
config.teleportDelay = 0.2  -- Increase delay

-- Add random variation:
local function getRandomDelay()
    return config.teleportDelay + math.random() * 0.1
end

-- Use in loop:
task.wait(getRandomDelay())
```

### Issue: Missing Keycaps

**Solution:** Adjust validation or scan depth

```lua
-- Remove size restrictions
local function isKeycapValid(keycap)
    return keycap and keycap:IsDescendantOf(workspace) and keycap:IsA("BasePart")
end

-- Increase scan depth (if keycaps are deeply nested)
-- Modify recursive scan to go deeper
```

### Issue: Slow Performance

**Solution:** Disable expensive features

```lua
config.sortByDistance = false   -- Skip pathfinding
config.showNotifications = false -- Skip notifications
config.tweenSpeed = 0           -- No tweening

-- Reduce UI update frequency
-- In update loop, change:
while task.wait(1) do  -- Update every 1 second instead of 0.5
```

### Issue: Character Getting Stuck

**Solution:** Increase height or add safety checks

```lua
config.teleportHeight = 5  -- Higher position

-- Add unstuck mechanism:
local lastPosition = humanoidRootPart.Position
task.spawn(function()
    while state.isTeleporting do
        task.wait(2)
        if (humanoidRootPart.Position - lastPosition).Magnitude < 1 then
            -- Stuck! Jump or teleport away
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 10, 0)
        end
        lastPosition = humanoidRootPart.Position
    end
end)
```

---

## Environment-Specific Configurations

### Small Maps (< 50 keycaps)
```lua
config.sortByDistance = false  -- Not needed
config.teleportDelay = 0       -- Full speed
config.batchSize = 999         -- No batching needed
```

### Large Maps (> 500 keycaps)
```lua
config.sortByDistance = true   -- Essential
config.batchSize = 100         -- Process in batches
config.showNotifications = false -- Reduce overhead
```

### Respawning Keycaps
```lua
config.loopTeleport = true     -- Continuous collection
config.autoScanOnStart = true  -- Rescan automatically
```

### One-Time Collection
```lua
config.loopTeleport = false    -- Single run
config.autoScanOnStart = true  -- Quick start
config.teleportDelay = 0       -- Fast as possible
```

---

## Best Practices

1. **Start Conservative:** Begin with safe settings, then optimize
2. **Test First:** Try on small areas before full maps
3. **Monitor Performance:** Watch for lag or issues
4. **Backup Settings:** Save configurations that work well
5. **Document Changes:** Note what you modified and why

## Additional Resources

- See `README.md` for feature overview
- See `QUICKSTART.md` for basic usage
- See `CHANGELOG.md` for version history

---

**Happy customizing! 🎨**
