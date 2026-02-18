import QtQuick
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell
import "../components" as C

WlrLayershell {
    id: notificationPopupLayer
    property var app
    property var notificationServer

    readonly property var popupNotifications: {
        if (app.dnd || !notificationServer || !notificationServer.trackedNotifications)
            return [];

        const values = notificationServer.trackedNotifications.values || [];
        return values.slice(Math.max(0, values.length - 3));
    }

    visible: popupNotifications.length > 0
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

    Column {
        anchors.right: parent.right
        spacing: app.sp("notificationPopupGap", 8)

        Repeater {
            model: popupNotifications

            delegate: C.NotificationPopupCard {
                required property var modelData

                width: app.sz("notificationPopupWidth", 376)

                notification: modelData
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
}
