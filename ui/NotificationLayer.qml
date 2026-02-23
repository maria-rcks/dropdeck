import QtQuick
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell
import "../components" as C

WlrLayershell {
    id: notificationPopupLayer
    property var app
    property var notificationServer

    readonly property var trackedNotifications: notificationServer && notificationServer.trackedNotifications
        ? notificationServer.trackedNotifications
        : null
    readonly property var notificationValues: trackedNotifications && trackedNotifications.values ? trackedNotifications.values : []
    readonly property var latestNotifications: {
        const values = notificationValues || [];
        return values.slice(Math.max(0, values.length - 3));
    }

    visible: !app.dnd && latestNotifications.length > 0
    color: "transparent"
    anchors {
        top: true
        right: true
    }
    margins {
        top: app.sp("notificationPopupMargin", 16)
        right: app.sp("notificationPopupMargin", 16)
    }
    implicitWidth: app.sz("notificationLayerWidth", 380)
    implicitHeight: app.sz("notificationLayerHeight", 600)
    layer: WlrLayer.Top
    keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: 0

    onLatestNotificationsChanged: {
        if (app && app.debugLoggingEnabled && app.debugLoggingEnabled())
            app.debugLog("notification-values count=" + latestNotifications.length + " dnd=" + app.dnd);
    }

    onVisibleChanged: {
        if (app && app.debugLoggingEnabled && app.debugLoggingEnabled())
            app.debugLog("notification-layer visible=" + visible + " count=" + latestNotifications.length + " dnd=" + app.dnd);
    }

    Column {
        anchors.right: parent.right
        spacing: app.sp("notificationPopupGap", 8)

        C.NotificationPopupCard {
            visible: latestNotifications.length > 0
            width: app.sz("notificationPopupWidth", 376)

            notification: latestNotifications.length > 0 ? latestNotifications[0] : null
            cardColor: app.s("toggleInactiveBg", "#0B0B0B")
            borderColor: app.c("border", "#1F1F1F")
            panelColor: app.s("sliderTrack", "#1A1A1A")
            textPrimary: app.c("textPrimary", "#FFFFFF")
            textSecondary: app.c("textSecondary", "#A1A1AA")
            cardGradientEnabled: app.fx("cardGradientEnabled", false)
            cardGradientOpacity: app.fx("cardGradientOpacity", 0.0)
            cardGradientStart: app.sf("cardGradient", "start", "#ffffff10")
            cardGradientEnd: app.sf("cardGradient", "end", "#00000010")
        }

        C.NotificationPopupCard {
            visible: latestNotifications.length > 1
            width: app.sz("notificationPopupWidth", 376)

            notification: latestNotifications.length > 1 ? latestNotifications[1] : null
            cardColor: app.s("toggleInactiveBg", "#0B0B0B")
            borderColor: app.c("border", "#1F1F1F")
            panelColor: app.s("sliderTrack", "#1A1A1A")
            textPrimary: app.c("textPrimary", "#FFFFFF")
            textSecondary: app.c("textSecondary", "#A1A1AA")
            cardGradientEnabled: app.fx("cardGradientEnabled", false)
            cardGradientOpacity: app.fx("cardGradientOpacity", 0.0)
            cardGradientStart: app.sf("cardGradient", "start", "#ffffff10")
            cardGradientEnd: app.sf("cardGradient", "end", "#00000010")
        }

        C.NotificationPopupCard {
            visible: latestNotifications.length > 2
            width: app.sz("notificationPopupWidth", 376)

            notification: latestNotifications.length > 2 ? latestNotifications[2] : null
            cardColor: app.s("toggleInactiveBg", "#0B0B0B")
            borderColor: app.c("border", "#1F1F1F")
            panelColor: app.s("sliderTrack", "#1A1A1A")
            textPrimary: app.c("textPrimary", "#FFFFFF")
            textSecondary: app.c("textSecondary", "#A1A1AA")
            cardGradientEnabled: app.fx("cardGradientEnabled", false)
            cardGradientOpacity: app.fx("cardGradientOpacity", 0.0)
            cardGradientStart: app.sf("cardGradient", "start", "#ffffff10")
            cardGradientEnd: app.sf("cardGradient", "end", "#00000010")
        }
    }
}
