# ⚡ Wind UI Keycap Teleporter

An enhanced Roblox keycap collection script with a modern Wind UI interface, smart pathfinding, and advanced features.

## 🌟 Features

### Core Features
- **🔍 Auto-Scan**: Automatically scans for keycaps on startup
- **⚡ Instant Teleport**: Ultra-fast teleportation with 0 delay
- **🧠 Smart Pathfinding**: Calculates shortest route using proximity sorting
- **⏸️ Pause/Resume**: Control teleportation mid-sequence
- **🔄 Loop Mode**: Continuous farming with automatic restart
- **📊 Real-time Statistics**: Live tracking of progress, speed, and time

### Advanced Features
- **Smooth Tweening**: Optional smooth teleportation animations
- **Skip Collected**: Automatically skip already collected keycaps
- **Custom Height**: Adjustable teleport height above keycaps
- **Batch Processing**: Efficient processing for large quantities
- **Hotkey Support**: Keyboard shortcuts for quick control

### UI Features
- **Modern Interface**: Beautiful Wind UI design
- **Multiple Tabs**: Organized controls, settings, hotkeys, and info
- **Real-time Updates**: Live status and statistics display
- **Customizable**: Extensive settings configuration
- **Notifications**: In-game notifications for important events

## 🎮 How to Use

### Installation
1. Copy the script from `wind-ui-teleporter.lua`
2. Paste into your Roblox executor
3. Execute the script
4. The UI will appear automatically

### Basic Usage
1. **Scan for Keycaps**: Click the "🔍 Scan for Keycaps" button
2. **Start Teleporting**: Click "⚡ Start Teleport" or press `T`
3. **Monitor Progress**: Watch real-time statistics in the Main tab
4. **Stop/Pause**: Use controls or hotkeys to manage teleportation

### Hotkeys
| Key | Action |
|-----|--------|
| `T` | Start/Stop Teleport |
| `P` | Pause/Resume |
| `R` | Rescan Keycaps |

## ⚙️ Settings

### Teleport Settings
- **Teleport Delay** (0-2s): Delay between each teleport
- **Teleport Height** (0-10): Height above keycap surface
- **Tween Speed** (0-1s): Smooth teleport animation speed (0 = instant)
- **Loop Teleport**: Enable continuous farming
- **Sort by Distance**: Use smart pathfinding for shortest route
- **Skip Collected**: Ignore already collected keycaps

### UI Settings
- **Show Notifications**: Toggle in-game notifications
- **Auto-Scan on Start**: Automatically scan when script loads

## 📊 Statistics Display

The Main tab displays real-time statistics:
- **Status**: Current operation status
- **Keycaps Found**: Total keycaps discovered in scan
- **Progress**: Current position in teleport sequence
- **Time**: Elapsed time for current operation
- **Speed**: Keycaps collected per second

## 🔧 Configuration

You can modify the default configuration at the top of the script:

```lua
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
```

## 🎯 Tabs Overview

### Main Tab
- Teleport controls (Start, Stop, Pause)
- Scanning functions
- Real-time statistics display

### Settings Tab
- Teleport behavior configuration
- UI preferences
- Performance options

### Hotkeys Tab
- Customizable keyboard shortcuts
- Quick action bindings

### Info Tab
- Version information
- Usage instructions
- Feature list

## 🚀 Performance

### Optimizations
- Efficient recursive scanning algorithm
- Smart pathfinding reduces travel distance
- Batch processing for large collections
- Minimal memory footprint
- Real-time validation to skip invalid keycaps

### Speed
- **Instant Mode**: 0ms delay (default)
- **Fast Mode**: 50ms delay (safer)
- **Safe Mode**: 100ms+ delay (most stable)

## 🛡️ Safety Features

- Validates keycaps before teleporting
- Checks if keycaps are still in workspace
- Skips invalid or deleted keycaps
- Pause/stop functionality for emergencies
- No client-side exploits detected by most anti-cheats

## 📝 Requirements

- Roblox Executor with `loadstring` support
- Internet connection (to load Wind UI library)
- Game with "keycaps" folder in workspace

## 🔍 Troubleshooting

### "Keycaps folder not found"
- Ensure the game has a folder named "keycaps" in workspace
- Check if keycaps are in a different location

### UI not appearing
- Check if your executor supports `loadstring`
- Verify internet connection for Wind UI download
- Try reloading the script

### Teleport not working
- Run a scan first before teleporting
- Check if character is loaded properly
- Verify HumanoidRootPart exists

### Slow performance
- Reduce tween speed to 0 for instant teleports
- Disable loop mode if not needed
- Close unnecessary programs

## 🆚 Comparison with Original

| Feature | Original | Wind UI Version |
|---------|----------|-----------------|
| UI Quality | Basic | Professional |
| Statistics | Minimal | Comprehensive |
| Controls | 1 Button | Multiple Tabs |
| Hotkeys | T only | T, P, R + Custom |
| Pathfinding | Basic | Smart Sorting |
| Pause/Resume | No | Yes |
| Loop Mode | No | Yes |
| Settings | Hardcoded | Adjustable |
| Notifications | Simple | Rich |
| Updates | None | Real-time |

## 📜 Version History

### v2.0 (Current)
- Integrated Wind UI library
- Added comprehensive settings
- Real-time statistics display
- Pause/resume functionality
- Loop mode for farming
- Smart pathfinding improvements
- Customizable hotkeys
- Multiple tab interface

### v1.0 (Original)
- Basic teleportation
- Simple UI
- Auto-scan feature
- T key hotkey

## 💡 Tips & Tricks

1. **Fastest Collection**: Set delay to 0, disable tweening
2. **Safest Collection**: Use 0.1s delay, enable notifications
3. **AFK Farming**: Enable loop mode, use safe delays
4. **Large Maps**: Use smart pathfinding to reduce travel time
5. **Quick Restart**: Use R key to rescan without reopening UI

## ⚠️ Disclaimer

This script is for educational purposes only. Use at your own risk. The author is not responsible for any bans or consequences from using this script.

## 🤝 Credits

- **UI Library**: Wind UI by Wind Scripts
- **Original Concept**: Basic Keycap Teleporter
- **Enhancement**: Advanced features and modern interface

## 📞 Support

For issues or suggestions:
1. Check the troubleshooting section
2. Verify all requirements are met
3. Test with a fresh executor instance

---

**Enjoy ultra-fast keycap collection with style! ⚡**
