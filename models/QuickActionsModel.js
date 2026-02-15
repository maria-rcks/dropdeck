function build(app, bluetooth) {
    return [
        {
            icon: "assets/icons/wifi.svg",
            active: app.wifiEnabled,
            disabled: !app.hasTool("nmcli"),
            action: function() { app.toggleWifi(); },
            rightAction: function() { app.openWifiChooser(); }
        },
        {
            icon: "assets/icons/bluetooth.svg",
            active: bluetooth.defaultAdapter && bluetooth.defaultAdapter.enabled,
            disabled: !bluetooth.defaultAdapter && !app.hasTool("bluetoothctl"),
            action: function() {
                if (bluetooth.defaultAdapter)
                    bluetooth.defaultAdapter.enabled = !bluetooth.defaultAdapter.enabled;
                else
                    app.refreshBluetoothDevices();
            },
            rightAction: function() { app.openBluetoothChooser(); }
        },
        {
            icon: "assets/icons/airplane.svg",
            active: app.airplaneEnabled,
            disabled: !app.hasTool("rfkill"),
            action: function() { app.toggleAirplane(); }
        },
        {
            icon: "assets/icons/mute.svg",
            active: app.volumeMuted,
            disabled: !app.hasTool("wpctl"),
            action: function() {
                app.runCommandIf("wpctl", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
                app.refreshVolume();
            }
        },
        {
            icon: app.dnd ? "assets/icons/bell_off.svg" : "assets/icons/bell.svg",
            active: app.dnd,
            action: function() { app.dnd = !app.dnd; },
            rightAction: function() { app.notificationHistoryOpen = true; }
        },
        {
            icon: "assets/icons/calendar_month.svg",
            active: false,
            action: function() { app.openCalendar(); }
        },
        {
            icon: "assets/icons/power.svg",
            active: false,
            action: function() { app.openPowerMenu(); }
        },
        {
            icon: "assets/icons/settings.svg",
            active: false,
            action: function() {
                app.refreshThemeList();
                app.settingsModalOpen = true;
            }
        }
    ];
}
