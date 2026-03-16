# Orion Drift – Cinematic Spectator Camera

A fully-featured cinematic camera script and ReShade integration for the
Orion Drift spectator system.

---

## File List

| File | Purpose |
|------|---------|
| `cinematic.camera.luau` | Main Luau camera script |
| `reshade_watcher.ps1` | PowerShell watcher – toggles ReShade via the GUI button |

---

## Installation

### 1 – Camera Script

Copy `cinematic.camera.luau` into:

```
C:\Users\<USERNAME>\Documents\Another-Axiom\A2\Cameras\Behaviors\
```

Start Orion Drift with the spectator client running.  
Open the **Cameras** panel (`F2`), find `cinematic.camera.luau`, and click **Activate**.  
Your custom GUI will appear in the **Current Camera** panel (`F3`).

---

## GUI Tabs

### Movement
| Setting | Description |
|---------|-------------|
| Field of View | Camera FOV (30–150°) |
| Movement Speed | Free-fly speed |
| Position Smoothing | Lag/damping on position (higher = smoother/laggier) |
| Rotation Smoothing | Same for rotation |

Controls: `WASD` = fly, `Q/E` = up/down, `Shift` = fast, `Ctrl` = slow.

---

### Follow Player
| Setting | Description |
|---------|-------------|
| Enable Follow Mode | Toggles follow vs free-fly |
| Player Index | Which player to follow (1-based) |
| Orbit Distance | How far behind the player the camera sits |
| Height Offset | Vertical offset above player |
| Follow Lag | How quickly the camera catches up (lower = snappier) |

---

### Path / Dolly
| Setting | Description |
|---------|-------------|
| Enable Path Mode | Activates spline-based dolly |
| Path Duration | Seconds for one full pass |
| Loop / Ping-pong | Loop restarts; ping-pong reverses |
| Add Keyframe (`V`) | Records current camera position as a waypoint |
| Clear All | Removes all keyframes |
| Play (`B`) / Stop | Starts/stops path playback |
| Auto-play on activate | Begins playback every time you switch to this camera |

Keyframes use a **Catmull-Rom spline** for smooth curved paths.

---

### Post FX
| Setting | Description |
|---------|-------------|
| Bloom Intensity | Glow strength |
| Bloom Threshold | Minimum brightness for glow |
| Depth of Field | Toggle shallow/deep focus |
| Focal Distance | Focus point distance |
| F-Stop | Aperture — lower = shallower DOF |
| Sensor Width | Affects DOF calculation (mm) |
| Chromatic Aberration | Lens fringe effect |
| Motion Blur | Frame-blend amount |

Quick buttons: **Shallow DOF**, **Broadcast**, **Clean / No FX**.

---

### Cinematic
| Setting | Description |
|---------|-------------|
| Letterbox | Black bars top/bottom (adjustable size) |
| ReShade ON/OFF | Saves toggle state to config JSON; watcher script acts on it |

---

### Presets
Save and load up to **5 named presets** that store every setting across all tabs.  
Presets are serialised into the camera config JSON automatically.

---

## ReShade Integration

### Setup

1. In ReShade's overlay → **Settings** → set **Effect Toggle Key** to `Scroll Lock`.
2. Run the watcher script in the background:

```powershell
powershell -ExecutionPolicy Bypass -File reshade_watcher.ps1
```

3. Use the **ReShade ON/OFF** button in the **Cinematic** tab.  
   The script monitors the camera config JSON (`customdata.reshadeEnabled`)  
   and sends `Scroll Lock` to the game window whenever it changes.

> **Note:** The spectator scripting API does not expose direct filesystem  
> writes, so the toggle is communicated through `saveConfig()`. The  
> PowerShell watcher bridges the gap.

---

## Config File Location

```
Documents\Another-Axiom\A2\Cameras\Configs\cinematic.camera.json
```

The `customdata` key inside that file stores all persisted settings.

---

## Requirements

- Orion Drift with the **PC Spectator Client** installed
- VSCode + [luau-lsp](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp) (recommended for editing)
- PowerShell 5+ (for ReShade watcher)
- ReShade installed in the Orion Drift install directory (for ReShade feature)

---

## Notes

- The spectator scripting system uses **Luau** (Roblox's typed Lua dialect).
- Camera scripts auto-reload on save — no restart needed.
- Multiple presets can reference the same script with different configs by  
  copying the `.json` config file (see official docs).
- Default cameras reference: `F2` = camera list, `F3` = current camera GUI,  
  `F4` = camera logs.

---

## Links

- [Official Spectator Docs](https://docs.spectator.oriondriftvr.com/)
- [Getting Started with Scripting](https://docs.spectator.oriondriftvr.com/getting-started-scripting.html)
- [Post Processing Reference](https://docs.spectator.oriondriftvr.com/post-processing.html)
- [Datamined Spectator Docs (GitHub)](https://github.com/0belous/A2-spectator-docs)
