function buildItems(app) {
    return [
        {
            id: "lock",
            title: "Lock",
            subtitle: app.hasTool("loginctl") ? "Lock current session" : "loginctl unavailable",
            icon: app.themedIcon("assets/icons/lock.svg", app.c("backgroundElevated", "#060606")),
            active: false,
            disabled: !app.hasTool("loginctl")
        },
        {
            id: "suspend",
            title: "Suspend",
            subtitle: app.hasTool("systemctl") ? "Sleep and keep session" : "systemctl unavailable",
            icon: app.themedIcon("assets/icons/suspend.svg", app.c("backgroundElevated", "#060606")),
            active: false,
            disabled: !app.hasTool("systemctl")
        },
        {
            id: "reboot",
            title: "Reboot",
            subtitle: app.hasTool("systemctl") ? "Restart the system" : "systemctl unavailable",
            icon: app.themedIcon("assets/icons/reboot.svg", app.c("backgroundElevated", "#060606")),
            active: false,
            disabled: !app.hasTool("systemctl")
        },
        {
            id: "shutdown",
            title: "Shutdown",
            subtitle: app.hasTool("systemctl") ? "Power off the system" : "systemctl unavailable",
            icon: app.themedIcon("assets/icons/power.svg", app.c("backgroundElevated", "#060606")),
            active: false,
            disabled: !app.hasTool("systemctl")
        },
        {
            id: "logout",
            title: "Logout",
            subtitle: app.hasTool("loginctl") ? "End this user session" : "loginctl unavailable",
            icon: app.themedIcon("assets/icons/logout.svg", app.c("backgroundElevated", "#060606")),
            active: false,
            disabled: !app.hasTool("loginctl")
        }
    ];
}

function execute(app, itemId) {
    if (itemId === "lock") {
        app.runCommandIf("loginctl", "loginctl lock-session");
    } else if (itemId === "suspend") {
        app.runCommandIf("systemctl", "systemctl suspend");
    } else if (itemId === "reboot") {
        app.runCommandIf("systemctl", "systemctl reboot");
    } else if (itemId === "shutdown") {
        app.runCommandIf("systemctl", "systemctl poweroff");
    } else if (itemId === "logout") {
        app.runCommandIf("loginctl", "loginctl terminate-user $USER");
    }
}
