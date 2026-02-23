import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Services.Notifications
import Quickshell.Bluetooth
import "components" as C
import "ui" as U
import "services/PowerService.js" as PowerService

ShellRoot {
    id: root

    property bool panelOpen: false
    property bool dragging: false
    property real openProgress: 0.0
    property real dragStartY: 0

    property bool dnd: false
    property var notificationHistory: []

    property bool wifiEnabled: false
    property string wifiSsid: "Disconnected"
    property bool airplaneEnabled: false

    property real brightnessPercent: 50
    property real volumePercent: 0
    property bool volumeMuted: false
    property bool brightnessBoostOn: false
    property bool flashlightOverlayOn: false
    property real brightnessBeforeBoost: 50
    property bool nightLightOn: false


    property string playerTitle: "Nothing playing"
    property string playerArtist: ""
    property bool playerPlaying: false
    property string playerArtUrl: ""

    property bool volumeDragging: false
    property bool brightnessDragging: false
    property real pendingVolume: -1
    property real pendingBrightness: -1

    property bool notificationHistoryOpen: false
    property bool calendarOpen: false
    property bool settingsModalOpen: false

    property real cpuPercent: 0
    property real memoryPercent: 0
    property real temperatureC: NaN
    property real cpuPrevTotal: -1
    property real cpuPrevIdle: -1
    property real batteryPercent: -1
    property string batteryCapacityPath: ""

    property var toolCaps: ({
        nmcli: false,
        rfkill: false,
        brightnessctl: false,
        wpctl: false,
        playerctl: false,
        bluetoothctl: false,
        loginctl: false,
        systemctl: false
    })

    property bool chooserOpen: false
    property string chooserType: ""
    property string chooserTitle: ""
    property var chooserItems: []
    property var availableThemes: []
    property string activeThemePath: ""
    property var fallbackThemePaths: [
        "themes/default.json",
        "themes/catppuccin-mocha.json",
        "themes/dracula.json",
        "themes/everforest-dark.json",
        "themes/gruvbox-dark.json",
        "themes/kanagawa.json",
        "themes/nord.json",
        "themes/one-dark-pro.json",
        "themes/rose-pine.json",
        "themes/solarized-dark.json",
        "themes/tokyo-night.json"
    ]
    property string userHomePath: String(Quickshell.env("HOME") || "")
    property string userConfigHomePath: String(Quickshell.env("XDG_CONFIG_HOME") || (userHomePath.length ? (userHomePath + "/.config") : ""))
    property string settingsFsPath: userConfigHomePath.length ? (userConfigHomePath + "/dropdeck-settings.json") : "settings.json"
    property string userThemesDirPath: userConfigHomePath.length ? (userConfigHomePath + "/dropdeck/themes") : ""

    property var defaultSettings: ({
        themes: [],
        spacingProfile: {
            scale: 1.0,
            extra: 0,
            roundTo: 1
        },
        colors: {
            background: "#000000",
            backgroundPanel: "#0A0A0A",
            backgroundCard: "#111111",
            border: "#1F1F1F",
            borderSubtle: "#171717",
            textPrimary: "#FFFFFF",
            textSecondary: "#A1A1AA",
            textMuted: "#71717A",
            accent: "#FFFFFF",
            accentMuted: "#D4D4D8",
            scrim: "#000000AA"
        },
        states: {
            toggleActiveBg: "#FFFFFF",
            toggleInactiveBg: "#0B0B0B",
            sliderTrack: "#141414",
            sliderFill: "#FFFFFF",
            sliderHandle: "#FFFFFF",
            notificationBg: "#0B0B0B"
        },
        radius: {
            sm: 10,
            md: 14,
            lg: 18,
            xl: 24,
            pill: 999
        },
        spacing: {
            controlGap: 10,
            panelContentGap: 14,
            panelWidthMargin: 40,
            panelHeightMargin: 28,
            notificationPopupGap: 8,
            notificationPopupMargin: 16
        },
        sizes: {
            quickTile: 88,
            panelMaxWidth: 980,
            panelMaxHeight: 860,
            panelGrabberWidth: 54,
            panelGrabberHeight: 5,
            notificationPopupWidth: 376,
            notificationLayerWidth: 380,
            notificationLayerHeight: 600
        },
        behavior: {
            dragOpenDistance: 220,
            dragReleaseThreshold: 0.15,
            panelToggleThreshold: 0.2,
            panelOpenThreshold: 0.98,
            scrimOpacity: 0.66
        },
        effects: {
            panelBackdropEnabled: false,
            panelBackdropOpacity: 0.0,
            panelGradientEnabled: false,
            panelGradientOpacity: 0.0,
            modalGradientEnabled: false,
            modalGradientOpacity: 0.0,
            cardGradientEnabled: false,
            cardGradientOpacity: 0.0,
            sliderFillGradientEnabled: false,
            toggleGradientEnabled: false,
            toggleGradientOpacity: 0.0,
            toggleHighlightOpacity: 0.0
        },
        surfaces: {
            panelBackdrop: {
                start: "#101010",
                end: "#080808"
            },
            panelGradient: {
                start: "#ffffff10",
                end: "#00000010"
            },
            cardGradient: {
                start: "#ffffff10",
                end: "#00000010"
            },
            sliderFillGradient: {
                start: "#ffffff",
                end: "#d4d4d8"
            },
            toggleGradient: {
                start: "#ffffff30",
                end: "#00000020"
            },
            modalGradient: {
                start: "#ffffff10",
                end: "#00000010"
            }
        },
        debug: {
            logging: false,
            actionTracing: false
        }
    })

    property var settings: ({})

    FileView {
        id: jsonFileView
        preload: false
        blockLoading: true
        blockAllReads: true
        printErrors: false
    }

    FileView {
        id: settingsWriteFile
        preload: false
        blockLoading: true
        blockAllReads: true
        blockWrites: false
        printErrors: false
    }

    property int quickTileSize: Math.round(root.sz("quickTile", 88))
    property int controlGap: Math.round(root.sp("controlGap", 10))
    property int mediaSquareSize: (quickTileSize * 2) + controlGap
    property int sliderCardWidth: mediaSquareSize + (controlGap * 2)

    function deepClone(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    function deepMerge(base, patch) {
        if (!patch || typeof patch !== "object")
            return base;

        for (const key in patch) {
            const value = patch[key];
            if (Array.isArray(value)) {
                base[key] = value.slice();
            } else if (value && typeof value === "object") {
                if (!base[key] || typeof base[key] !== "object" || Array.isArray(base[key]))
                    base[key] = {};
                deepMerge(base[key], value);
            } else {
                base[key] = value;
            }
        }
        return base;
    }

    function toFileUrl(filePath) {
        const p = String(filePath || "").trim();
        if (!p.length)
            return "";
        if (p.startsWith("file://"))
            return p;
        if (p.startsWith("/"))
            return "file://" + encodeURI(p);
        return String(Qt.resolvedUrl(p));
    }

    function loadJson(filePath) {
        try {
            jsonFileView.path = toFileUrl(filePath);
            const text = jsonFileView.text();
            if (text && text.length > 0)
                return JSON.parse(text);
        } catch (e) {
            debugLog("Failed to parse " + String(filePath) + ": " + e);
        }
        return null;
    }

    function applyParsedSettings(parsed) {
        const merged = deepClone(root.defaultSettings);
        let firstTheme = "";

        if (parsed && parsed.themes && Array.isArray(parsed.themes)) {
            for (let i = 0; i < parsed.themes.length; ++i) {
                const themePath = String(parsed.themes[i] || "").trim();
                if (!themePath.length)
                    continue;
                if (!firstTheme.length)
                    firstTheme = themePath;
                const themeData = loadJson(themePath);
                if (themeData)
                    deepMerge(merged, themeData);
            }
        }

        if (parsed)
            deepMerge(merged, parsed);

        root.settings = merged;
        root.activeThemePath = firstTheme;
    }

    function readSettingsObject() {
        return loadJson(root.settingsFsPath) || loadJson("settings.json") || {};
    }

    function loadSettings() {
        const fromXdg = loadJson(root.settingsFsPath);
        const fromLegacy = fromXdg ? null : loadJson("settings.json");
        const parsed = fromXdg || fromLegacy;
        if (!fromXdg && fromLegacy)
            writeSettingsJson(fromLegacy);
        applyParsedSettings(parsed);
    }

    function getSetting(path, fallback) {
        const parts = String(path || "").split(".");
        let node = root.settings;
        for (let i = 0; i < parts.length; ++i) {
            const part = parts[i];
            if (!part.length)
                continue;
            if (!node || typeof node !== "object" || node[part] === undefined)
                return fallback;
            node = node[part];
        }
        return node;
    }

    function g(path, fallback) {
        return getSetting(path, fallback);
    }

    function debugLoggingEnabled() {
        return Boolean(getSetting("debug.logging", false));
    }

    function debugActionTracingEnabled() {
        return Boolean(getSetting("debug.actionTracing", false));
    }

    function debugLog(message) {
        if (debugLoggingEnabled())
            console.log("[dropdeck] " + String(message || ""));
    }

    function c(key, fallback) {
        return getSetting("colors." + key, fallback);
    }

    function s(key, fallback) {
        return getSetting("states." + key, fallback);
    }

    function r(key, fallback) {
        return getSetting("radius." + key, fallback);
    }

    function b(key, fallback) {
        return getSetting("behavior." + key, fallback);
    }

    function fx(key, fallback) {
        return getSetting("effects." + key, fallback);
    }

    function sf(group, key, fallback) {
        return getSetting("surfaces." + group + "." + key, fallback);
    }

    function sz(key, fallback) {
        return getSetting("sizes." + key, fallback);
    }

    function sp(key, fallback) {
        const raw = Number(getSetting("spacing." + key, fallback));
        const scale = Number(getSetting("spacingProfile.scale", 1.0));
        const extra = Number(getSetting("spacingProfile.extra", 0));
        const roundTo = Math.max(1, Number(getSetting("spacingProfile.roundTo", 1)));
        const scaled = (isNaN(raw) ? Number(fallback) : raw) * (isNaN(scale) ? 1.0 : scale) + (isNaN(extra) ? 0 : extra);
        return Math.round(scaled / roundTo) * roundTo;
    }

    Component.onCompleted: {
        loadSettings();
        availableThemes = buildThemeEntries(fallbackThemePaths);
        refreshThemeList();
        refreshToolCaps();
        detectBatteryPath();
    }

    function clamp(v, min, max) {
        return Math.max(min, Math.min(max, v));
    }

    function colorLuma(hexColor, fallbackHex) {
        const src = String(hexColor || fallbackHex || "#000000");
        const s = src.startsWith("#") ? src.slice(1) : src;
        let r = 0;
        let g = 0;
        let b = 0;

        if (s.length === 8) {
            r = parseInt(s.slice(2, 4), 16);
            g = parseInt(s.slice(4, 6), 16);
            b = parseInt(s.slice(6, 8), 16);
        } else if (s.length === 6) {
            r = parseInt(s.slice(0, 2), 16);
            g = parseInt(s.slice(2, 4), 16);
            b = parseInt(s.slice(4, 6), 16);
        } else {
            return 0;
        }

        return (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;
    }

    function themedIcon(iconPath, backgroundColor) {
        const path = String(iconPath || "");
        if (!path.startsWith("assets/icons/"))
            return iconPath;
        const useBlack = colorLuma(backgroundColor, "#000000") > 0.6;
        return useBlack ? path.replace("assets/icons/", "assets/icons/black/") : path;
    }

    function writeSettingsJson(obj) {
        try {
            settingsWriteFile.path = toFileUrl(root.settingsFsPath);
            settingsWriteFile.setText(JSON.stringify(obj, null, 2) + "\n");
            return true;
        } catch (e) {
        }
        return false;
    }

    function setByPath(target, path, value) {
        const parts = String(path || "").split(".").filter(Boolean);
        if (!parts.length)
            return;

        let node = target;
        for (let i = 0; i < parts.length - 1; ++i) {
            const key = parts[i];
            if (!node[key] || typeof node[key] !== "object" || Array.isArray(node[key]))
                node[key] = {};
            node = node[key];
        }
        node[parts[parts.length - 1]] = value;
    }

    function updateSetting(path, value) {
        const parsed = readSettingsObject();
        setByPath(parsed, path, value);
        if (writeSettingsJson(parsed))
            applyParsedSettings(parsed);
    }

    function applyTheme(themePath) {
        if (!themePath || String(themePath).length === 0)
            return;
        const parsed = readSettingsObject();
        parsed.themes = [String(themePath)];
        if (writeSettingsJson(parsed))
            applyParsedSettings(parsed);
    }

    function configFsPath(rel) {
        const baseUrl = String(Qt.resolvedUrl("."));
        const basePath = baseUrl.startsWith("file://") ? decodeURIComponent(baseUrl.slice(7)) : baseUrl;
        const cleanBase = basePath.endsWith("/") ? basePath : (basePath + "/");
        return cleanBase + String(rel || "");
    }

    function buildThemeEntries(paths) {
        const out = [];
        const list = Array.isArray(paths) ? paths : [];
        for (let i = 0; i < list.length; ++i) {
            const p = String(list[i] || "").trim();
            if (!p.length)
                continue;
            const data = root.loadJson(p) || {};
            out.push({
                path: p,
                name: String(data.name || p.split("/").pop().replace(/\.json$/i, "")),
                title: String(data.title || ""),
                description: String(data.description || ""),
                colors: data.colors || {},
                states: data.states || {}
            });
        }
        return out;
    }

    function refreshThemeList() {
        const appThemeDir = configFsPath("themes");
        const dirs = [shQuote(appThemeDir)];
        if (root.userThemesDirPath.length)
            dirs.push(shQuote(root.userThemesDirPath));
        const cmd = "for d in " + dirs.join(" ") + "; do [ -d \"$d\" ] && find \"$d\" -maxdepth 1 -type f -name '*.json'; done | sort -u";
        themeListQuery.exec(["sh", "-c", cmd]);
    }

    function hasTool(name) {
        return root.toolCaps && root.toolCaps[name] === true;
    }

    function refreshToolCaps() {
        capsQuery.exec(["sh", "-c", "for t in nmcli rfkill brightnessctl wpctl playerctl bluetoothctl loginctl systemctl; do command -v $t >/dev/null 2>&1 && echo \"$t=1\" || echo \"$t=0\"; done"]);
    }

    function detectBatteryPath() {
        batteryPathQuery.exec(["sh", "-c", "for f in /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/battery*/capacity; do [ -r \"$f\" ] && { echo \"$f\"; exit 0; }; done; for d in /sys/class/power_supply/*; do [ -r \"$d/type\" ] || continue; grep -qi '^Battery$' \"$d/type\" || continue; [ -r \"$d/capacity\" ] && { echo \"$d/capacity\"; exit 0; }; done; echo ''"]);
    }

    function setOpenProgress(v) {
        openProgress = clamp(v, 0, 1);
        panelOpen = openProgress > root.b("panelOpenThreshold", 0.98);
    }

    function openPanel() {
        dragging = false;
        setOpenProgress(1);
    }

    function closePanel() {
        dragging = false;
        chooserOpen = false;
        notificationHistoryOpen = false;
        calendarOpen = false;
        settingsModalOpen = false;
        setOpenProgress(0);
    }

    function togglePanel() {
        if (openProgress > root.b("panelToggleThreshold", 0.2)) {
            closePanel();
        } else {
            openPanel();
        }
    }

    function runCommand(command) {
        const cmd = String(command || "").trim();
        if (!cmd.length)
            return;
        commandRunner.exec(["sh", "-c", cmd]);
    }

    function runCommandIf(toolName, command) {
        if (!hasTool(toolName))
            return false;
        runCommand(command);
        return true;
    }

    function shQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    function quickActionIcon(index) {
        switch (index) {
        case 0:
            return "assets/icons/wifi.svg";
        case 1:
            return "assets/icons/bluetooth.svg";
        case 2:
            return "assets/icons/airplane.svg";
        case 3:
            return "assets/icons/mute.svg";
        case 4:
            return dnd ? "assets/icons/bell_off.svg" : "assets/icons/bell.svg";
        case 5:
            return "assets/icons/calendar_month.svg";
        case 6:
            return "assets/icons/power.svg";
        case 7:
            return "assets/icons/settings.svg";
        default:
            return "assets/icons/settings.svg";
        }
    }

    function quickActionActive(index) {
        switch (index) {
        case 0:
            return wifiEnabled;
        case 1:
            return Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled;
        case 2:
            return airplaneEnabled;
        case 3:
            return volumeMuted;
        case 4:
            return dnd;
        default:
            return false;
        }
    }

    function quickActionDisabled(index) {
        switch (index) {
        case 0:
            return !hasTool("nmcli");
        case 1:
            return !Bluetooth.defaultAdapter && !hasTool("bluetoothctl");
        case 2:
            return !hasTool("rfkill");
        case 3:
            return !hasTool("wpctl");
        default:
            return false;
        }
    }

    function triggerQuickAction(index) {
        if (quickActionDisabled(index)) {
            if (debugActionTracingEnabled())
                debugLog("quick-action blocked index=" + index);
            return;
        }

        if (debugActionTracingEnabled())
            debugLog("quick-action click index=" + index + " icon=" + quickActionIcon(index));

        switch (index) {
        case 0:
            toggleWifi();
            break;
        case 1:
            if (Bluetooth.defaultAdapter)
                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
            else
                refreshBluetoothDevices();
            break;
        case 2:
            toggleAirplane();
            break;
        case 3:
            runCommandIf("wpctl", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
            refreshVolume();
            break;
        case 4:
            dnd = !dnd;
            break;
        case 5:
            openCalendar();
            break;
        case 6:
            openPowerMenu();
            break;
        case 7:
            refreshThemeList();
            settingsModalOpen = true;
            break;
        default:
            break;
        }
    }

    function triggerQuickActionRight(index) {
        if (quickActionDisabled(index)) {
            if (debugActionTracingEnabled())
                debugLog("quick-action right-click blocked index=" + index);
            return;
        }

        if (debugActionTracingEnabled())
            debugLog("quick-action right-click index=" + index + " icon=" + quickActionIcon(index));

        switch (index) {
        case 0:
            openWifiChooser();
            break;
        case 1:
            openBluetoothChooser();
            break;
        case 4:
            notificationHistoryOpen = true;
            break;
        default:
            break;
        }
    }

    function openWifiChooser() {
        chooserType = "wifi";
        chooserTitle = "Wi-Fi networks";
        chooserOpen = true;
        refreshWifiNetworks();
    }

    function openBluetoothChooser() {
        chooserType = "bluetooth";
        chooserTitle = "Bluetooth devices";
        chooserOpen = true;
        refreshBluetoothDevices();
    }

    function refreshWifi() {
        if (!hasTool("nmcli")) {
            wifiEnabled = false;
            wifiSsid = "Unavailable";
            return;
        }
        wifiQuery.exec([
            "sh",
            "-c",
            "nmcli -t -f WIFI g; echo '---'; nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1==\"yes\"{print $2; exit}'"
        ]);
    }

    function toggleWifi() {
        if (!runCommandIf("nmcli", "nmcli radio wifi " + (wifiEnabled ? "off" : "on")))
            return;
        wifiRefreshTimer.restart();
    }

    function refreshAirplane() {
        if (!hasTool("rfkill")) {
            airplaneEnabled = false;
            return;
        }
        airplaneQuery.exec(["sh", "-c", "rfkill list | awk 'BEGIN{on=0} /Soft blocked: yes|Hard blocked: yes/{on=1} END{print on?\"on\":\"off\"}'"]);
    }

    function toggleAirplane() {
        if (!runCommandIf("rfkill", "rfkill " + (airplaneEnabled ? "unblock all" : "block all")))
            return;
        airplaneRefreshTimer.restart();
        wifiRefreshTimer.restart();
    }

    function enableFlashlight() {
        brightnessBeforeBoost = brightnessPercent;
        brightnessBoostOn = true;
        flashlightOverlayOn = true;
        brightnessPercent = 100;
        pendingBrightness = 100;
        brightnessSetTimer.restart();
        closePanel();
    }

    function disableFlashlight() {
        if (!brightnessBoostOn && !flashlightOverlayOn)
            return;

        brightnessBoostOn = false;
        flashlightOverlayOn = false;
        const target = clamp(brightnessBeforeBoost, 1, 100);
        brightnessPercent = target;
        pendingBrightness = target;
        brightnessSetTimer.restart();
    }

    function toggleBrightnessBoost() {
        if (brightnessBoostOn || flashlightOverlayOn)
            disableFlashlight();
        else
            enableFlashlight();
    }

    function toggleNightLight() {
        nightLightOn = !nightLightOn;
        if (nightLightOn) {
            runCommand("pkill -x gammastep >/dev/null 2>&1 || true; pkill -x wlsunset >/dev/null 2>&1 || true; (command -v wlsunset >/dev/null 2>&1 && nohup wlsunset -t 3600 -T 6500 >/dev/null 2>&1 &) || (command -v gammastep >/dev/null 2>&1 && nohup gammastep -O 3600 >/dev/null 2>&1 &) || true");
        } else {
            runCommand("(command -v gammastep >/dev/null 2>&1 && gammastep -x >/dev/null 2>&1) || true; pkill -x gammastep >/dev/null 2>&1 || true; pkill -x wlsunset >/dev/null 2>&1 || true");
        }
    }

    function refreshBrightness() {
        brightnessQuery.exec(["sh", "-c", "(command -v brightnessctl >/dev/null 2>&1 && brightnessctl g && brightnessctl m) || echo ''"]);
    }

    function refreshVolume() {
        volumeQuery.exec(["sh", "-c", "(command -v wpctl >/dev/null 2>&1 && wpctl get-volume @DEFAULT_AUDIO_SINK@) || echo ''"]);
    }

    function refreshPlayer() {
        if (!hasTool("playerctl")) {
            playerPlaying = false;
            playerArtist = "";
            playerTitle = "Nothing playing";
            playerArtUrl = "";
            return;
        }
        playerQuery.exec(["sh", "-c", "playerctl status 2>/dev/null; echo '---'; playerctl metadata --format '{{artist}}' 2>/dev/null; echo '---'; playerctl metadata --format '{{title}}' 2>/dev/null; echo '---'; playerctl metadata --format '{{mpris:artUrl}}' 2>/dev/null"]);
    }

    function refreshBattery() {
        const p = String(batteryCapacityPath || "").trim();
        if (!p.length) {
            batteryPercent = -1;
            return;
        }
        batteryQuery.exec(["sh", "-c", "cat " + shQuote(p) + " 2>/dev/null || echo ''"]);
    }

    function refreshSystemStats() {
        systemStatsQuery.exec(["sh", "-c", "awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8; print $5; exit}' /proc/stat; echo '---'; awk '/MemTotal:/{t=$2}/MemAvailable:/{a=$2} END{if(t>0) printf \"%.0f\", (t-a)*100/t; else print \"0\"}' /proc/meminfo; echo '---'; if [ -r /sys/class/thermal/thermal_zone0/temp ]; then awk '{printf \"%.1f\", $1/1000}' /sys/class/thermal/thermal_zone0/temp; elif command -v sensors >/dev/null 2>&1; then sensors 2>/dev/null | awk '/Package id 0:|Tctl:/{gsub(/[+°C]/,\"\",$4); print $4; exit}'; else echo ''; fi"]);
    }

    function openPowerMenu() {
        chooserType = "power";
        chooserTitle = "Power";
        chooserItems = PowerService.buildItems(root);
        chooserOpen = true;
    }

    function openCalendar() {
        calendarOpen = true;
    }

    function refreshWifiNetworks() {
        if (!hasTool("nmcli")) {
            chooserItems = [{
                id: "unavailable",
                title: "Wi-Fi unavailable",
                subtitle: "nmcli was not found",
                active: false,
                disabled: true
            }];
            return;
        }
        wifiListQuery.exec(["sh", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan auto | head -n 24"]);
    }

    function refreshBluetoothDevices() {
        if (!hasTool("bluetoothctl")) {
            chooserItems = [{
                id: "unavailable",
                title: "Bluetooth unavailable",
                subtitle: "bluetoothctl was not found",
                active: false,
                disabled: true
            }];
            return;
        }
        bluetoothListQuery.exec(["sh", "-c", "bluetoothctl devices; echo '---'; bluetoothctl devices Connected"]);
    }

    function selectChooserItem(item) {
        if (!item || item.disabled)
            return;

        if (chooserType === "wifi") {
            if (!runCommandIf("nmcli", "nmcli dev wifi connect " + shQuote(item.id)))
                return;
            chooserOpen = false;
            wifiRefreshTimer.restart();
            return;
        }

        if (chooserType === "bluetooth") {
            if (!runCommandIf("bluetoothctl", "bluetoothctl connect " + shQuote(item.id)))
                return;
            chooserOpen = false;
            return;
        }

        if (chooserType === "power") {
            chooserOpen = false;
            PowerService.execute(root, item.id);
            return;
        }
    }

    Process {
        id: capsQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const next = root.deepClone(root.toolCaps);
                const lines = text.trim().length > 0 ? text.trim().split("\n") : [];
                for (let i = 0; i < lines.length; ++i) {
                    const parts = lines[i].split("=");
                    if (parts.length !== 2)
                        continue;
                    const key = String(parts[0]).trim();
                    next[key] = String(parts[1]).trim() === "1";
                }
                root.toolCaps = next;
                root.refreshWifi();
                root.refreshAirplane();
                root.refreshBrightness();
                root.refreshVolume();
                root.refreshPlayer();
                root.refreshBattery();
            }
        }
    }

    Process {
        id: batteryPathQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.batteryCapacityPath = text.trim();
                root.refreshBattery();
            }
        }
    }

    Process {
        id: commandRunner
    }

    Process {
        id: wifiQuery
        stdout: StdioCollector {
            id: wifiCollector
            waitForEnd: true
            onStreamFinished: {
                const raw = text.trim();
                const parts = raw.split("---");
                if (parts.length >= 1) {
                    const wifiState = parts[0].trim().toLowerCase();
                    root.wifiEnabled = wifiState === "enabled";
                }

                if (parts.length >= 2) {
                    const ssid = parts[1].trim();
                    root.wifiSsid = ssid.length > 0 ? ssid : "Disconnected";
                } else {
                    root.wifiSsid = "Disconnected";
                }
            }
        }
    }

    Process {
        id: airplaneQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.airplaneEnabled = text.trim().toLowerCase() === "on"
        }
    }

    Process {
        id: wifiListQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const lines = text.trim().length > 0 ? text.trim().split("\n") : [];
                const bySsid = {};

                for (let i = 0; i < lines.length; ++i) {
                    const cols = lines[i].split(":");
                    if (cols.length < 4)
                        continue;

                    const inUse = cols[0].trim() === "*";
                    const ssid = cols[1].trim();
                    if (ssid.length === 0)
                        continue;

                    const signalText = cols[2].trim();
                    const signalNum = Number(signalText);
                    const sec = cols.slice(3).join(":").trim();

                    const existing = bySsid[ssid];
                    const shouldReplace = !existing || inUse || (isFinite(signalNum) && signalNum > existing.signalNum);

                    if (shouldReplace) {
                        bySsid[ssid] = {
                            id: ssid,
                            title: ssid,
                            subtitle: signalText + "%" + (sec.length > 0 ? " • " + sec : ""),
                            active: inUse,
                            signalNum: isFinite(signalNum) ? signalNum : 0
                        };
                    } else if (existing && inUse) {
                        existing.active = true;
                    }
                }

                const items = Object.keys(bySsid).map(k => bySsid[k]);
                items.sort((a, b) => {
                    if (a.active !== b.active)
                        return a.active ? -1 : 1;
                    return (b.signalNum || 0) - (a.signalNum || 0);
                });

                root.chooserItems = items;
            }
        }
    }

    Process {
        id: bluetoothListQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const raw = text.trim();
                const parts = raw.split("---");
                const allLines = parts.length > 0 ? parts[0].trim().split("\n") : [];
                const connectedLines = parts.length > 1 ? parts[1].trim().split("\n") : [];
                const connected = {};

                for (let i = 0; i < connectedLines.length; ++i) {
                    const m = connectedLines[i].match(/^Device\s+([0-9A-F:]+)\s+(.+)$/i);
                    if (m)
                        connected[m[1]] = true;
                }

                const items = [];
                for (let i = 0; i < allLines.length; ++i) {
                    const m = allLines[i].match(/^Device\s+([0-9A-F:]+)\s+(.+)$/i);
                    if (!m)
                        continue;
                    const mac = m[1];
                    const name = m[2];
                    items.push({
                        id: mac,
                        title: name,
                        subtitle: mac,
                        active: connected[mac] === true
                    });
                }

                root.chooserItems = items;
            }
        }
    }

    Process {
        id: themeListQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const lines = text.trim().length > 0 ? text.trim().split("\n") : [];
                const normalized = [];
                for (let i = 0; i < lines.length; ++i) {
                    const abs = String(lines[i] || "").trim();
                    if (!abs.length)
                        continue;
                    const cfg = root.configFsPath("");
                    const rel = abs.startsWith(cfg) ? abs.slice(cfg.length) : abs;
                    normalized.push(rel);
                }
                const entries = root.buildThemeEntries(normalized);
                root.availableThemes = entries.length > 0 ? entries : root.buildThemeEntries(root.fallbackThemePaths);
            }
        }
    }

    Process {
        id: brightnessQuery
        stdout: StdioCollector {
            id: brightnessCollector
            waitForEnd: true
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 2) {
                    const current = Number(lines[0]);
                    const max = Number(lines[1]);
                    if (max > 0) {
                        const nextBrightness = root.clamp((current / max) * 100, 0, 100);
                        root.brightnessPercent = nextBrightness;

                    }
                }
            }
        }
    }

    Process {
        id: volumeQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const raw = text.trim();
                const m = raw.match(/Volume:\s*([0-9.]+)/);
                const nextMuted = raw.indexOf("[MUTED]") !== -1;

                if (m && m.length >= 2) {
                    const v = Number(m[1]);
                    if (isFinite(v)) {
                        const nextVolume = root.clamp(v * 100, 0, 150);
                        root.volumePercent = nextVolume;
                        root.volumeMuted = nextMuted;

                        return;
                    }
                }

                root.volumeMuted = nextMuted;
            }
        }
    }

    Process {
        id: playerQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const parts = text.split("---");
                const status = (parts.length > 0 ? parts[0] : "").trim().toLowerCase();
                const artist = (parts.length > 1 ? parts[1] : "").trim();
                const title = (parts.length > 2 ? parts[2] : "").trim();
                const artUrl = (parts.length > 3 ? parts[3] : "").trim();

                root.playerPlaying = status === "playing";
                root.playerArtist = artist;
                root.playerTitle = title.length > 0 ? title : "Nothing playing";
                root.playerArtUrl = artUrl;
            }
        }
    }

    Process {
        id: batteryQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const pct = Number(text.trim());
                root.batteryPercent = isFinite(pct) ? pct : -1;
            }
        }
    }

    Process {
        id: systemStatsQuery
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const parts = text.split("---");
                const cpuLines = (parts.length > 0 ? parts[0] : "").trim().split("\n");
                const total = Number(cpuLines.length > 0 ? cpuLines[0] : "");
                const idle = Number(cpuLines.length > 1 ? cpuLines[1] : "");
                const mem = Number((parts.length > 1 ? parts[1] : "").trim());
                const temp = Number((parts.length > 2 ? parts[2] : "").trim());

                if (isFinite(total) && isFinite(idle)) {
                    if (root.cpuPrevTotal >= 0 && total > root.cpuPrevTotal) {
                        const totalDiff = total - root.cpuPrevTotal;
                        const idleDiff = idle - root.cpuPrevIdle;
                        if (totalDiff > 0)
                            root.cpuPercent = root.clamp((1 - idleDiff / totalDiff) * 100, 0, 100);
                    }
                    root.cpuPrevTotal = total;
                    root.cpuPrevIdle = idle;
                }

                if (isFinite(mem))
                    root.memoryPercent = root.clamp(mem, 0, 100);

                root.temperatureC = isFinite(temp) ? temp : NaN;
            }
        }
    }

    NotificationServer {
        id: notificationServer
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: false

        onNotification: notification => {
            Qt.callLater(() => {
                if (notification)
                    notification.tracked = true;
            });

            const copy = root.notificationHistory.slice();
            copy.push(notification);
            root.notificationHistory = copy.slice(Math.max(0, copy.length - 20));
        }
    }

    Timer {
        id: wifiRefreshTimer
        interval: 5000
        running: root.hasTool("nmcli")
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshWifi()
    }

    Timer {
        id: brightnessRefreshTimer
        interval: 180
        running: !root.brightnessDragging && root.pendingBrightness < 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshBrightness()
    }

    Timer {
        id: volumeRefreshTimer
        interval: 180
        running: !root.volumeDragging && root.pendingVolume < 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshVolume()
    }

    Timer {
        id: playerRefreshTimer
        interval: 1200
        running: root.hasTool("playerctl")
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshPlayer()
    }

    Timer {
        id: playerActionSyncTimer
        interval: 220
        repeat: false
        onTriggered: root.refreshPlayer()
    }

    Timer {
        id: systemStatsRefreshTimer
        interval: 1600
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshSystemStats()
    }

    Timer {
        id: batteryRefreshTimer
        interval: 12000
        running: String(root.batteryCapacityPath || "").length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshBattery()
    }

    Timer {
        id: volumeSetTimer
        interval: 45
        repeat: false
        onTriggered: {
            if (root.pendingVolume >= 0) {
                const target = root.pendingVolume;
                root.runCommand("(command -v wpctl >/dev/null 2>&1 && wpctl set-volume @DEFAULT_AUDIO_SINK@ " + target.toFixed(3) + ") || true");
                volumeAfterSetTimer.restart();
            }
        }
    }

    Timer {
        id: volumeAfterSetTimer
        interval: 110
        repeat: false
        onTriggered: {
            root.pendingVolume = -1;
            root.refreshVolume();
        }
    }

    Timer {
        id: brightnessSetTimer
        interval: 70
        repeat: false
        onTriggered: {
            if (root.pendingBrightness >= 0) {
                const target = Math.round(root.pendingBrightness);
                root.runCommand("(command -v brightnessctl >/dev/null 2>&1 && brightnessctl set " + target + "%) || true");
                brightnessAfterSetTimer.restart();
            }
        }
    }

    Timer {
        id: brightnessAfterSetTimer
        interval: 130
        repeat: false
        onTriggered: {
            root.pendingBrightness = -1;
            root.refreshBrightness();
        }
    }

    Timer {
        id: airplaneRefreshTimer
        interval: 7000
        running: root.hasTool("rfkill")
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshAirplane()
    }

    SystemClock {
        id: systemClock
        enabled: true
        precision: SystemClock.Minutes
    }

    IpcHandler {
        target: "control"

        function toggle() {
            root.togglePanel();
        }

        function open() {
            root.openPanel();
        }

        function close() {
            root.closePanel();
        }
    }

    Behavior on openProgress {
        NumberAnimation {
            duration: 170
            easing.type: Easing.OutCubic
        }
    }

    U.TopHandleLayer {
        app: root
    }

    WlrLayershell {
        id: overlay
        visible: root.openProgress > 0.001 || root.dragging
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        layer: WlrLayer.Overlay
        keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, root.openProgress * root.b("scrimOpacity", 0.66))

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.ArrowCursor
                onClicked: root.closePanel()
            }

            C.ModalHost {
                app: root
            }

            Rectangle {
                id: panelSheet
                width: parent.width
                height: parent.height
                x: 0
                y: -height + (height * root.openProgress)
                radius: 0
                clip: false
                color: "transparent"
                border.width: 0
                border.color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - root.sp("panelWidthMargin", 40), root.sz("panelMaxWidth", 980))
                    height: Math.min(parent.height - root.sp("panelHeightMargin", 28), root.sz("panelMaxHeight", 860))
                    spacing: root.sp("panelContentGap", 14)

                    Rectangle {
                        id: panelGrabber
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: root.sz("panelGrabberWidth", 54)
                        Layout.preferredHeight: root.sz("panelGrabberHeight", 5)
                        radius: Math.round(root.sz("panelGrabberHeight", 5) / 2)
                        color: root.c("textMuted", "#71717A")
                    }

                    C.PanelHeader {
                        id: topBar
                        dateTime: systemClock.date
                        batteryPercent: root.batteryPercent
                        cpuPercent: root.cpuPercent
                        memoryPercent: root.memoryPercent
                        temperatureC: root.temperatureC
                        textPrimary: root.c("textPrimary", "#FFFFFF")
                        textSecondary: root.c("textSecondary", "#A1A1AA")
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: root.controlGap

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -Math.round((panelGrabber.height + topBar.height + root.controlGap) / 2)
                                spacing: root.controlGap

                            GridLayout {
                                id: controlGrid
                                columns: 4
                                rowSpacing: root.controlGap
                                columnSpacing: root.controlGap

                                C.MediaPlayerCard {
                                    id: mediaCard
                                    Layout.columnSpan: 2
                                    Layout.rowSpan: 2
                                    Layout.preferredWidth: root.mediaSquareSize
                                    Layout.preferredHeight: root.mediaSquareSize
                                    title: root.playerTitle
                                    artist: root.playerArtist
                                    playing: root.playerPlaying
                                    artUrl: root.playerArtUrl
                                    cardColor: root.c("backgroundPanel", "#0A0A0A")
                                    borderColor: root.c("border", "#1F1F1F")
                                    textPrimary: root.c("textPrimary", "#FFFFFF")
                                    textSecondary: root.c("textSecondary", "#A1A1AA")
                                    cardGradientEnabled: root.fx("cardGradientEnabled", false)
                                    cardGradientOpacity: root.fx("cardGradientOpacity", 0.0)
                                    cardGradientStart: root.sf("cardGradient", "start", "#ffffff10")
                                    cardGradientEnd: root.sf("cardGradient", "end", "#00000010")
                                    onPreviousClicked: {
                                        root.runCommandIf("playerctl", "playerctl previous");
                                        playerActionSyncTimer.restart();
                                    }
                                    onPlayPauseClicked: {
                                        root.runCommandIf("playerctl", "playerctl play-pause");
                                        root.playerPlaying = !root.playerPlaying;
                                        playerActionSyncTimer.restart();
                                    }
                                    onNextClicked: {
                                        root.runCommandIf("playerctl", "playerctl next");
                                        playerActionSyncTimer.restart();
                                    }
                                }

                                Repeater {
                                    model: 8

                                    delegate: C.QuickIconToggle {
                                        required property int index

                                        readonly property string actionIcon: root.quickActionIcon(index)
                                        readonly property bool actionDisabled: root.quickActionDisabled(index)

                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredWidth: root.quickTileSize
                                        Layout.preferredHeight: root.quickTileSize
                                        size: root.quickTileSize
                                        iconSize: Math.round(root.quickTileSize * 0.45)
                                        iconSource: root.themedIcon(actionIcon, root.s("toggleInactiveBg", "#0B0B0B"))
                                        activeIconSource: root.themedIcon(actionIcon, root.s("toggleActiveBg", "#FFFFFF"))
                                        active: root.quickActionActive(index)
                                        enabled: !actionDisabled
                                        activeColor: root.s("toggleActiveBg", "#FFFFFF")
                                        inactiveColor: root.s("toggleInactiveBg", "#0B0B0B")
                                        borderColor: root.c("border", "#1F1F1F")
                                        gradientEnabled: root.fx("toggleGradientEnabled", false)
                                        gradientOpacity: root.fx("toggleGradientOpacity", 0.0)
                                        gradientStart: root.sf("toggleGradient", "start", "#ffffff30")
                                        gradientEnd: root.sf("toggleGradient", "end", "#00000020")
                                        highlightOpacity: root.fx("toggleHighlightOpacity", 0.0)
                                        inactiveOpacity: 1.0
                                        iconOpacity: actionDisabled ? 0.45 : 1.0
                                        onClicked: root.triggerQuickAction(index)
                                        onRightClicked: root.triggerQuickActionRight(index)
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                spacing: root.controlGap

                                C.SliderCard {
                                    Layout.preferredWidth: root.sliderCardWidth
                                    Layout.preferredHeight: (root.mediaSquareSize - root.controlGap) / 2
                                    iconSource: root.themedIcon(root.volumeMuted ? "assets/icons/mute.svg" : "assets/icons/volume.svg", root.c("backgroundPanel", "#0A0A0A"))
                                    filledIconSource: root.themedIcon(root.volumeMuted ? "assets/icons/mute.svg" : "assets/icons/volume.svg", root.s("sliderFill", "#FFFFFF"))
                                    rightText: ""
                                    from: 0
                                    to: 1.5
                                    value: root.volumePercent / 100.0
                                    cardColor: root.c("backgroundPanel", "#0A0A0A")
                                    textColor: root.c("textSecondary", "#A1A1AA")
                                    fillColor: root.s("sliderFill", "#FFFFFF")
                                    borderColor: root.c("border", "#1F1F1F")
                                    cardGradientEnabled: root.fx("cardGradientEnabled", false)
                                    cardGradientOpacity: root.fx("cardGradientOpacity", 0.0)
                                    cardGradientStart: root.sf("cardGradient", "start", "#ffffff10")
                                    cardGradientEnd: root.sf("cardGradient", "end", "#00000010")
                                    fillGradientEnabled: root.fx("sliderFillGradientEnabled", false)
                                    fillGradientStart: root.sf("sliderFillGradient", "start", "#ffffff")
                                    fillGradientEnd: root.sf("sliderFillGradient", "end", "#d4d4d8")
                                    opacity: 1.0
                                    onDragActiveChanged: active => {
                                        root.volumeDragging = active;
                                        if (!active && root.pendingVolume < 0)
                                            volumeAfterSetTimer.restart();
                                    }
                                    onMoved: value => {
                                        root.volumePercent = value * 100;
                                        root.pendingVolume = value;
                                        volumeSetTimer.restart();
                                    }
                                }

                                C.SliderCard {
                                    Layout.preferredWidth: root.sliderCardWidth
                                    Layout.preferredHeight: (root.mediaSquareSize - root.controlGap) / 2
                                    iconSource: root.themedIcon("assets/icons/brightness.svg", root.c("backgroundPanel", "#0A0A0A"))
                                    filledIconSource: root.themedIcon("assets/icons/brightness.svg", root.s("sliderFill", "#FFFFFF"))
                                    rightText: ""
                                    from: 1
                                    to: 100
                                    value: root.brightnessPercent
                                    cardColor: root.c("backgroundPanel", "#0A0A0A")
                                    textColor: root.c("textSecondary", "#A1A1AA")
                                    fillColor: root.s("sliderFill", "#FFFFFF")
                                    borderColor: root.c("border", "#1F1F1F")
                                    cardGradientEnabled: root.fx("cardGradientEnabled", false)
                                    cardGradientOpacity: root.fx("cardGradientOpacity", 0.0)
                                    cardGradientStart: root.sf("cardGradient", "start", "#ffffff10")
                                    cardGradientEnd: root.sf("cardGradient", "end", "#00000010")
                                    fillGradientEnabled: root.fx("sliderFillGradientEnabled", false)
                                    fillGradientStart: root.sf("sliderFillGradient", "start", "#ffffff")
                                    fillGradientEnd: root.sf("sliderFillGradient", "end", "#d4d4d8")
                                    opacity: 1.0
                                    onDragActiveChanged: active => {
                                        root.brightnessDragging = active;
                                        if (!active && root.pendingBrightness < 0)
                                            brightnessAfterSetTimer.restart();
                                    }
                                    onMoved: value => {
                                        root.brightnessPercent = value;
                                        root.pendingBrightness = value;
                                        brightnessSetTimer.restart();
                                    }
                                }

                                RowLayout {
                                    Layout.preferredWidth: root.sliderCardWidth
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: root.controlGap

                                    C.QuickIconToggle {
                                        Layout.preferredWidth: root.quickTileSize
                                        Layout.preferredHeight: root.quickTileSize
                                        size: root.quickTileSize
                                        iconSize: Math.round(root.quickTileSize * 0.45)
                                        iconSource: root.themedIcon(root.brightnessBoostOn ? "assets/icons/flashlight_on.svg" : "assets/icons/flashlight_off.svg", root.s("toggleInactiveBg", "#0B0B0B"))
                                        activeIconSource: root.themedIcon("assets/icons/flashlight_on.svg", root.s("toggleActiveBg", "#FFFFFF"))
                                        active: root.brightnessBoostOn
                                        activeColor: root.s("toggleActiveBg", "#FFFFFF")
                                        inactiveColor: root.s("toggleInactiveBg", "#0B0B0B")
                                        borderColor: root.c("border", "#1F1F1F")
                                        gradientEnabled: root.fx("toggleGradientEnabled", false)
                                        gradientOpacity: root.fx("toggleGradientOpacity", 0.0)
                                        gradientStart: root.sf("toggleGradient", "start", "#ffffff30")
                                        gradientEnd: root.sf("toggleGradient", "end", "#00000020")
                                        highlightOpacity: root.fx("toggleHighlightOpacity", 0.0)
                                        enabled: root.hasTool("brightnessctl")
                                        iconOpacity: root.hasTool("brightnessctl") ? 1.0 : 0.45
                                        onClicked: root.toggleBrightnessBoost()
                                    }

                                    C.QuickIconToggle {
                                        Layout.preferredWidth: root.quickTileSize
                                        Layout.preferredHeight: root.quickTileSize
                                        size: root.quickTileSize
                                        iconSize: Math.round(root.quickTileSize * 0.45)
                                        iconSource: root.themedIcon("assets/icons/nightlight.svg", root.s("toggleInactiveBg", "#0B0B0B"))
                                        activeIconSource: root.themedIcon("assets/icons/nightlight.svg", root.s("toggleActiveBg", "#FFFFFF"))
                                        active: root.nightLightOn
                                        activeColor: root.s("toggleActiveBg", "#FFFFFF")
                                        inactiveColor: root.s("toggleInactiveBg", "#0B0B0B")
                                        borderColor: root.c("border", "#1F1F1F")
                                        gradientEnabled: root.fx("toggleGradientEnabled", false)
                                        gradientOpacity: root.fx("toggleGradientOpacity", 0.0)
                                        gradientStart: root.sf("toggleGradient", "start", "#ffffff30")
                                        gradientEnd: root.sf("toggleGradient", "end", "#00000020")
                                        highlightOpacity: root.fx("toggleHighlightOpacity", 0.0)
                                        onClicked: root.toggleNightLight()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    U.FlashlightLayer {
        app: root
    }

    U.NotificationLayer {
        app: root
        notificationServer: notificationServer
    }
}
}
