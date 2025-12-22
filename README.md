# ⚡ Roblox Keycap Teleporter Collection

A collection of enhanced Roblox keycap collection scripts with modern UI, smart pathfinding, and advanced features.

## 📁 Available Scripts

### 1. **wind-ui-teleporter.lua** (Recommended)
The most feature-rich version with professional Wind UI library integration.

**Features:**
- ✨ Modern Wind UI interface
- 📊 Real-time statistics dashboard
- ⚙️ Comprehensive settings panel
- 🎮 Multiple tabs (Main, Settings, Hotkeys, Info)
- 🔧 Customizable hotkeys
- 📈 Advanced analytics

**Requirements:**
- Internet connection (to load Wind UI library)
- Executor with `loadstring` support

**Best for:** Users who want the most polished and feature-complete experience.

---

### 2. **standalone-teleporter.lua** (No Internet Required)
Custom-built modern UI without external dependencies.

**Features:**
- 🎨 Beautiful custom UI with Discord-inspired theme
- 📊 Real-time statistics
- ⚙️ Adjustable settings with sliders and toggles
- 🖱️ Draggable window
- 🎯 All core teleportation features

**Requirements:**
- No internet connection needed
- Works on any executor

**Best for:** Users who want a modern UI without external dependencies or internet connection.

---

## 🚀 Quick Start

### Option 1: Wind UI Version (Recommended)
```lua
-- Copy and paste the contents of wind-ui-teleporter.lua into your executor
-- The script will auto-load Wind UI and create the interface
```

### Option 2: Standalone Version
```lua
-- Copy and paste the contents of standalone-teleporter.lua into your executor
-- No internet connection required!
```

## ✨ Key Features (All Versions)

### Core Features
- ⚡ **Ultra-Fast Teleportation**: Instant or customizable delay
- 🧠 **Smart Pathfinding**: Calculates shortest route automatically
- 🔍 **Auto-Scan**: Finds all keycaps on startup
- ⏸️ **Pause/Resume**: Control mid-sequence
- 🔄 **Loop Mode**: Continuous farming
- 📊 **Statistics**: Real-time tracking

### Controls
- **T Key**: Start/Stop teleportation
- **P Key**: Pause/Resume
- **R Key**: Rescan keycaps
- **UI Buttons**: Full control panel

## 📊 Feature Comparison

| Feature | Wind UI | Standalone |
|---------|---------|------------|
| Modern UI | ✅ | ✅ |
| Internet Required | ✅ | ❌ |
| Multiple Tabs | ✅ | ❌ |
| Custom Themes | ✅ | ✅ (Fixed) |
| Real-time Stats | ✅ | ✅ |
| Draggable Window | ✅ | ✅ |
| Settings Panel | ✅ | ✅ |
| Hotkeys | ✅ | ✅ |
| Loop Mode | ✅ | ✅ |
| Smart Pathfinding | ✅ | ✅ |

## ⚙️ Configuration

Both versions include configurable settings:

```lua
- Teleport Delay: 0-2 seconds
- Teleport Height: 0-10 studs
- Tween Speed: 0-1 seconds (0 = instant)
- Loop Mode: Enable/Disable
- Sort by Distance: Enable/Disable
- Notifications: Enable/Disable
- Auto-Scan: Enable/Disable
```

## 🎮 Usage Guide

### First Time Setup
1. Choose which version you want to use
2. Copy the script contents
3. Paste into your Roblox executor
4. Execute the script
5. The UI will appear automatically

### Basic Usage
1. **Scan**: Click "Scan Keycaps" or press R
2. **Start**: Click "Start Teleport" or press T
3. **Monitor**: Watch real-time statistics
4. **Stop/Pause**: Use buttons or P key

### Advanced Usage
- Adjust teleport delay for safer collection
- Enable loop mode for AFK farming
- Customize height for different keycap sizes
- Use tween speed for smoother movement

## 📈 Performance Tips

### Fastest Collection
```
- Teleport Delay: 0
- Tween Speed: 0
- Sort by Distance: ON
```

### Safest Collection
```
- Teleport Delay: 0.1-0.2
- Tween Speed: 0
- Notifications: ON
```

### AFK Farming
```
- Loop Mode: ON
- Teleport Delay: 0.1
- Auto-Scan: ON
```

## 🛡️ Safety

- ✅ No game-breaking exploits
- ✅ Validates all keycaps before teleporting
- ✅ Graceful error handling
- ✅ Emergency stop functionality
- ⚠️ Use at your own risk

## 🐛 Troubleshooting

### "Keycaps folder not found"
- Ensure your game has a "keycaps" folder in workspace
- Check if keycaps are in a different location

### UI not appearing
- Verify executor supports GUI creation
- Check if script executed without errors
- Try restarting Roblox

### Teleport not working
- Scan for keycaps first
- Ensure character is loaded
- Check executor permissions

### Performance issues
- Reduce tween speed to 0
- Disable loop mode if not needed
- Close other scripts

## 📝 Documentation

For detailed documentation, see:
- `Keyless/README.md` - Comprehensive guide
- Script comments - Inline documentation

## 🔄 Version History

### v2.0 (Current)
- Added Wind UI integration
- Created standalone version
- Enhanced pathfinding algorithm
- Real-time statistics
- Multiple control options
- Comprehensive settings

### v1.0 (Original)
- Basic teleportation
- Simple UI
- T key hotkey

## ⚠️ Disclaimer

These scripts are for educational purposes only. Use at your own risk. The authors are not responsible for any consequences, including but not limited to account bans or game restrictions.

## 🤝 Credits

- **UI Library**: Wind UI by Wind Scripts (wind-ui version)
- **Original Concept**: Basic Keycap Teleporter
- **Enhanced by**: Advanced features and modern UI implementation

## 📞 Support

For issues:
1. Check the troubleshooting section
2. Read the detailed documentation in `Keyless/README.md`
3. Verify all requirements are met

---

**Choose your version and start collecting keycaps with style! ⚡**