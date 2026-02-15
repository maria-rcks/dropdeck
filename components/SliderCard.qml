import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: card

    function clamp(v, lo, hi) {
        return Math.max(lo, Math.min(hi, v));
    }

    property url iconSource
    property url filledIconSource: ""
    property real iconFlipThreshold: 0.10
    property string rightText: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property real wheelStep: Math.max((to - from) / 48, (to - from) > 10 ? 1 : 0.01)

    property color cardColor: "#0A0A0A"
    property color textColor: "#FFFFFF"
    property color fillColor: "#FFFFFF"
    property color borderColor: "#1F1F1F"

    property bool cardGradientEnabled: false
    property color cardGradientStart: "#ffffff12"
    property color cardGradientEnd: "#00000012"
    property real cardGradientOpacity: 0.0

    property bool fillGradientEnabled: false
    property color fillGradientStart: "#ffffff"
    property color fillGradientEnd: "#dcdcdc"
    property real fillGradientOpacity: 1.0

    signal moved(real value)
    signal dragActiveChanged(bool active)

    radius: 18
    clip: true
    color: cardColor
    border.color: borderColor
    border.width: 1

    Rectangle {
        anchors.fill: parent
        radius: card.radius
        visible: card.cardGradientEnabled && card.cardGradientOpacity > 0
        opacity: card.cardGradientOpacity
        gradient: Gradient {
            GradientStop { position: 0.0; color: card.cardGradientStart }
            GradientStop { position: 1.0; color: card.cardGradientEnd }
        }
    }

    Rectangle {
        id: fillLayer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Math.max(0, parent.width * s.visualPosition)
        radius: card.radius
        color: card.fillColor
        opacity: 1.0

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: card.fillGradientEnabled
            opacity: card.fillGradientOpacity
            gradient: Gradient {
                GradientStop { position: 0.0; color: card.fillGradientStart }
                GradientStop { position: 1.0; color: card.fillGradientEnd }
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14

        Image {
            id: sliderIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            source: {
                const useFilled = s.visualPosition >= card.iconFlipThreshold && String(card.filledIconSource).length > 0;
                const chosen = useFilled ? card.filledIconSource : card.iconSource;
                const src = String(chosen);
                if (src.startsWith("file:") || src.startsWith("/") || src.startsWith("qrc:"))
                    return chosen;
                return Qt.resolvedUrl("../" + src);
            }
            sourceSize.width: 28
            sourceSize.height: 28
            smooth: true
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: card.rightText
            color: card.textColor
            font.pixelSize: 13
            visible: text.length > 0
        }
    }

    Slider {
        id: s
        anchors.fill: parent
        from: card.from
        to: card.to
        value: card.value
        live: true
        onMoved: card.moved(value)
        onPressedChanged: card.dragActiveChanged(pressed)

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const delta = event.angleDelta.y !== 0 ? (event.angleDelta.y / 120.0) : (event.pixelDelta.y / 16.0);
                if (delta === 0)
                    return;
                const next = card.clamp(s.value + delta * card.wheelStep, card.from, card.to);
                s.value = next;
                card.moved(next);
                event.accepted = true;
            }
        }

        background: Rectangle { color: "transparent" }
        handle: Rectangle {
            width: 1
            height: 1
            radius: 1
            color: "transparent"
        }
    }
}
