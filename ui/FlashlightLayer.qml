import QtQuick
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell

WlrLayershell {
    id: flashlightOverlay
    property var app

    visible: app.flashlightOverlayOn
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    layer: WlrLayer.Overlay
    keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusiveZone: 0

    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"
        focus: true

        Keys.onPressed: event => {
            event.accepted = true;
            app.disableFlashlight();
        }

        Keys.onReleased: event => {
            event.accepted = true;
            app.disableFlashlight();
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
            cursorShape: Qt.ArrowCursor
            onPressed: mouse => {
                mouse.accepted = true;
                app.disableFlashlight();
            }
            onWheel: wheel => {
                wheel.accepted = true;
                app.disableFlashlight();
            }
        }
    }
}
