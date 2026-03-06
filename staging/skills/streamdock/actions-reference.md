# StreamDock Action UUID Reference

Complete catalog of built-in and plugin action UUIDs with settings schemas.

## System Actions

### Page Navigation
| UUID | Name | Notes |
|------|------|-------|
| `com.hotspot.streamdock.page.next` | Next Page | |
| `com.hotspot.streamdock.page.previous` | Previous Page | |
| `com.hotspot.streamdock.page.change` | Change Page | |
| `com.hotspot.streamdock.page.goto` | Go to Page | |
| `com.hotspot.streamdock.page.indicator` | Page Indicator | Shows current page number |

### Profile Management
| UUID | Name | Settings |
|------|------|----------|
| `com.hotspot.streamdock.profile.rotate` | Scene Shift | `{"DeviceUUID": "", "ProfileUUID": "TARGET-UUID"}` or `"PreviousScene"` |
| `com.hotspot.streamdock.profile.openchild` | Open Folder | `{"ProfileUUID": "CHILD-UUID.sdProfile"}` |
| `com.hotspot.streamdock.profile.backtoparent` | Back to Parent | |

### App / File / URL
| UUID | Name | Settings |
|------|------|----------|
| `com.hotspot.streamdock.system.open` | Open App/File | `{"path": "/Applications/App.app"}` |
| `com.hotspot.streamdock.system.openApps` | Open Apps | |
| `com.hotspot.streamdock.system.close` | Close App | |
| `com.hotspot.streamdock.system.website` | Open Website | `{"openInBrowser": true, "path": "https://..."}` |

### Input
| UUID | Name | Settings |
|------|------|----------|
| `com.hotspot.streamdock.system.hotkey` | Hotkey | See hotkey schema below |
| `com.hotspot.streamdock.system.hotkeySwitch` | Hotkey Switch | |
| `com.hotspot.streamdock.system.text` | Type Text | |
| `com.hotspot.streamdock.system.password` | Secure Text | |
| `com.hotspot.streamdock.mouse.event` | Mouse Event | `{"mouseButtonIndex": 1, "mouseEventIndex": 0, "mouseRadioButtonIndex": 0}` |
| `com.hotspot.streamdock.system.KnobOperatingGroup` | Knob Group | For rotary encoders |

### Device Control
| UUID | Name |
|------|------|
| `com.hotspot.streamdock.device.brightness` | Device Brightness |
| `com.hotspot.streamdock.device.devsleep` | Device Sleep |

### Touch Bar / Media (macOS)
| UUID | Name |
|------|------|
| `com.hotspot.streamdock.touchbar.volume` | Volume Slider |
| `com.hotspot.streamdock.touchbar.volumeup` | Volume Up |
| `com.hotspot.streamdock.touchbar.volumedown` | Volume Down |
| `com.hotspot.streamdock.touchbar.mute` | Mute |
| `com.hotspot.streamdock.touchbar.playpause` | Play/Pause |
| `com.hotspot.streamdock.touchbar.nexttrack` | Next Track |
| `com.hotspot.streamdock.touchbar.previoustrack` | Previous Track |
| `com.hotspot.streamdock.touchbar.screenshot` | Screenshot |
| `com.hotspot.streamdock.touchbar.siri` | Siri |
| `com.hotspot.streamdock.touchbar.sleep` | Sleep |
| `com.hotspot.streamdock.touchbar.launchpad` | Launchpad |
| `com.hotspot.streamdock.touchbar.dispatchcenter` | Mission Control |
| `com.hotspot.streamdock.touchbar.desktopsaver` | Desktop Saver |
| `com.hotspot.streamdock.touchbar.increasescreenbrightness` | Brightness Up |
| `com.hotspot.streamdock.touchbar.decreasescreenbrightness` | Brightness Down |
| `com.hotspot.streamdock.touchbar.screen.brightness` | Brightness Slider |

### Multimedia
| UUID | Name |
|------|------|
| `com.hotspot.streamdock.system.multimedia` | Media Controls |
| `com.hotspot.streamdock.system.volume` | System Volume |

### Multi-Action
| UUID | Name | Description |
|------|------|-------------|
| `com.hotspot.streamdock.multiactions.ActionTrigger` | Action Trigger | Sequential actions with delays |
| `com.hotspot.streamdock.multiactions.ActionWheel` | Action Wheel | Carousel — rotate through actions |
| `com.hotspot.streamdock.multiactions.LunBo` | Rotation | Animated rotation |
| `com.hotspot.streamdock.multiactions.routine` | Routine | Named action sequences |
| `com.hotspot.streamdock.multiactions.toggle` | Toggle | Two-state toggle |
| `com.hotspot.streamdock.multiactions.delay` | Delay | Timer between actions (2ms–200ms) |

### Other Built-ins
| UUID | Name |
|------|------|
| `com.hotspot.streamdock.memo.action1` | Notes History |
| `com.hotspot.streamdock.memo.action2` | To-Do Recorder |
| `com.hotspot.streamdock.soundboard.playaudio` | Play Audio |
| `com.hotspot.streamdock.soundboard.stopaudioplay` | Stop Audio |
| `com.hotspot.streamdock.plain.text` | Plain Text Display |
| `com.hotspot.streamdock.network.udp` | UDP Networking |

---

## Installed Plugin Actions

### Mic Mute (com.fredemmott.micmutetoggle)
| UUID | Name |
|------|------|
| `com.fredemmott.micmutetoggle.toggle` | Toggle Mute |
| `com.fredemmott.micmutetoggle.mute` | Mute |
| `com.fredemmott.micmutetoggle.unmute` | Unmute |

### Zoom (com.lostdomain.zoom)
| UUID | Name |
|------|------|
| `com.lostdomain.zoom.mutetoggle` | Mute Toggle |
| `com.lostdomain.zoom.videotoggle` | Video Toggle |
| `com.lostdomain.zoom.sharetoggle` | Share Toggle |
| `com.lostdomain.zoom.focus` | Focus |
| `com.lostdomain.zoom.leave` | Leave Meeting |
| `com.lostdomain.zoom.recordcloudtoggle` | Cloud Record Toggle |
| `com.lostdomain.zoom.recordlocaltoggle` | Local Record Toggle |
| `com.lostdomain.zoom.customshortcut` | Custom Shortcut |

### OBS Studio (com.hotspot.streamdock.obsstudio)
| UUID | Name |
|------|------|
| `com.hotspot.streamdock.obsstudio.scene` | Scene |
| `com.hotspot.streamdock.obsstudio.source` | Source |
| `com.hotspot.streamdock.obsstudio.record` | Record |
| `com.hotspot.streamdock.obsstudio.stream` | Stream |
| `com.hotspot.streamdock.obsstudio.studiomode` | Studio Mode |
| `com.hotspot.streamdock.obsstudio.mixeraudio` | Mixer Audio |
| `com.hotspot.streamdock.obsstudio.screenshot` | Screenshot |
| `com.hotspot.streamdock.obsstudio.transition` | Transition |
| `com.hotspot.streamdock.obsstudio.virtualcamera` | Virtual Camera |

### Obsidian (com.moz.obsidian-for-streamdock)
| UUID | Name | Settings |
|------|------|----------|
| `...obsidian.daily-note` | Daily Note | `{"vault": "VaultName"}` |
| `...obsidian.open-note` | Open Note | `{"vault": "...", "note_path": "/path/to/note"}` |
| `...obsidian.open-vault` | Open Vault | |
| `...obsidian.run-command` | Run Command | |
| `...obsidian.web-viewer` | Web Viewer | |

### Time (com.mirabox.streamdock.time)
| UUID | Name | Settings |
|------|------|----------|
| `...time.action1` | World Time | `{"zone": "system", "theme": "theme1"}` |
| `...time.action2` | Timer | `{"surplus": 60000, "timing": "60000"}` |
| `...time.action3` | Countdown | `{"color": "rgb(0,255,0)"}` |

### DevOps (dev.santiagomartin.devops)
| UUID | Name |
|------|------|
| `...devops.github-action` | GitHub Actions |
| `...devops.github-notifications` | GitHub Notifications |
| `...devops.vercel-action` | Vercel |

### API / Web Requests
| UUID | Name |
|------|------|
| `com.github.mjbnz.sd-api-request` | REST API Request |
| `gg.datagram.web-requests.http` | HTTP Request |
| `gg.datagram.web-requests.websocket` | WebSocket |

---

## Hotkey Settings Schema

```json
{
  "Coalesce": true,
  "Hotkeys": [
    {
      "KeyCmd": false,
      "KeyCtrl": false,
      "KeyShift": false,
      "KeyOption": false,
      "KeyCmd_Mac": false,
      "KeyShift_Mac": false,
      "KeyModifiers": 65536,
      "VKeyCode": 0,
      "VKeyCode_Mac": 0,
      "NativeCode": -1,
      "QTKeyCode": -1,
      "RKeyCmd": false,
      "RKeyCtrl": false,
      "RKeyShift": false,
      "RKeyOption": false
    }
  ],
  "hotkeyRadioButtonIndex": 0
}
```

### Common macOS Key Codes (VKeyCode_Mac)

| Key | Code | Key | Code |
|-----|------|-----|------|
| A | 0 | Return | 36 |
| S | 1 | Tab | 48 |
| D | 2 | Space | 49 |
| F | 3 | Delete | 51 |
| H | 4 | Escape | 53 |
| G | 5 | Cmd | 55 |
| Z | 6 | Shift | 56 |
| X | 7 | Option | 58 |
| C | 8 | Control | 59 |
| V | 9 | F1-F12 | 122-111 |

---

## Plugin Manifest Structure (for creating custom plugins)

```
com.example.myplugin.sdPlugin/
├── manifest.json
├── plugin/
│   ├── index.js          # Node.js entry
│   └── package.json
├── propertyInspector/     # Settings UI (optional)
│   └── index.html
└── images/
    ├── action_icon.png    # 40×40 (80×80 @2x)
    └── plugin_icon.png    # 128×128
```

Plugin SDK supports: JavaScript, Node.js, Vue.js, Python, C++, Qt.
All communicate via WebSocket JSON protocol.

SDK Docs: https://sdk.key123.vip/en/guide/overview.html
GitHub: https://github.com/MiraboxSpace/StreamDock-Plugin-SDK
