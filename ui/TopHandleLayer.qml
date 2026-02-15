import QtQuick
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell

WlrLayershell {
    id: topHandle
    property var app

    visible: true
    color: "transparent"
    implicitHeight: 2
    anchors {
        top: true
        left: true
        right: true
    }
    layer: WlrLayer.Overlay
    keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: 0

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeVerCursor

            onPressed: mouse => {
                app.dragging = true;
                app.dragStartY = mouse.y;
            }

            onPositionChanged: mouse => {
                if (!pressed)
                    return;

                const delta = mouse.y - app.dragStartY;
                app.setOpenProgress(delta / app.b("dragOpenDistance", 220.0));
            }

            onReleased: {
                if (app.openProgress > app.b("dragReleaseThreshold", 0.15))
                    app.openPanel();
                else
                    app.closePanel();
            }
        }
    }
}
