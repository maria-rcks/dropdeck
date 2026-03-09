<div align="center">
  <h2>DropDeck</h2>
  <img src="assets/repo/banner.png" alt="Dropdeck Banner" width="1000" />
  <em>Just like you swipe-down in your Phone, but for your Linux desktop.</em>
</div>

## Features

- **Phone-style drag-down panel** for quick access to controls.
- **Clickable header clock** that can flip between local time and an alternate timezone.
- **Quick toggles** for Wi-Fi, Bluetooth, Airplane mode, and DND.
- **Media controls** (play/pause, next/previous, metadata/art when available).
- **Notification popups + history** so alerts are visible but manageable.
- **Power menu** with lock, suspend, reboot, shutdown, and logout.
- **Theme system** with multiple bundled themes and runtime switching.

## Why Dropdeck?

I was never a fan of the _bar_ / _docks_ solutions on Linux. Since my screen is small, I want to be able use as much of it as possible.

So that’s what I did: an _invisible_ menu that I can pull down at any time _(just like my phone)_ to access things more quickly.

If you think Dropdeck would be useful to you, go ahead and try it — any feedback is welcome.

## Installation (AUR)

```bash
yay -S dropdeck-git
```

Then start it with the systemd user service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now dropdeck.service
```

## Requirements

| Requirements | Used for |
| :----------- | :------- |
| `nmcli` | Wi-Fi state + network listing/connection |
| `rfkill` | Airplane mode toggle |
| `brightnessctl` | Brightness read/write |
| `wpctl` | Volume read/write + mute |
| `playerctl` | Media controls + metadata |
| `bluetoothctl` | Bluetooth device list/connect |
| `loginctl` | Lock/logout actions |
| `systemctl` | Suspend/reboot/poweroff |
| `wlsunset` or `gammastep` | Night light toggle |

## Clock configuration

Each time you open the pull-down, the clock starts on your local time. Click it to switch to the alternate timezone clock.

The default alternate clock is San Francisco:

```json
{
  "clock": {
    "alternateEnabled": true,
    "alternateTimeZone": "America/Los_Angeles",
    "alternateLabel": "San Francisco"
  }
}
```
