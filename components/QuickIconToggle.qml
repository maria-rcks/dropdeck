import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property url iconSource
    property bool active: false
    property int size: 56
    property int iconSize: 24
    property color activeColor: "#ffffff"
    property color inactiveColor: "#0B0B0B"
    property color borderColor: "#1F1F1F"
    property real inactiveOpacity: 1.0
    property real iconOpacity: 1.0
    property url activeIconSource: ""
    property bool enabled: true

    property bool gradientEnabled: false
    property color gradientStart: "#ffffff22"
    property color gradientEnd: "#00000022"
    property real gradientOpacity: 0.0
    property color highlightColor: "#ffffff"
    property real highlightOpacity: 0.0

    signal clicked
    signal rightClicked

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: width / 2
        clip: true
        color: root.active ? root.activeColor : root.inactiveColor
        opacity: root.active ? 1.0 : root.inactiveOpacity
        border.color: root.borderColor
        border.width: border.color === "#00000000" ? 0 : 1

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: root.gradientEnabled && root.gradientOpacity > 0
            opacity: root.gradientOpacity
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.gradientStart }
                GradientStop { position: 1.0; color: root.gradientEnd }
            }
        }

        Rectangle {
            id: glareSource
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Math.max(1, parent.height * 0.04)
            width: parent.width * 0.72
            height: Math.max(2, parent.height * 0.24)
            radius: height / 2
            color: root.highlightColor
            opacity: root.highlightOpacity
            visible: root.highlightOpacity > 0
            layer.enabled: true
            layer.effect: OpacityMask { maskSource: glareMask }
        }

        Rectangle {
            id: glareMask
            anchors.fill: parent
            radius: parent.radius
            visible: false
        }

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Image {
        id: iconImage
        anchors.centerIn: parent
        source: {
            const chosen = root.active && String(root.activeIconSource).length > 0 ? root.activeIconSource : root.iconSource;
            const s = String(chosen);
            if (s.startsWith("file:") || s.startsWith("/") || s.startsWith("qrc:"))
                return chosen;
            return Qt.resolvedUrl("../" + s);
        }
        sourceSize.width: root.iconSize
        sourceSize.height: root.iconSize
        opacity: root.iconOpacity
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
            else
                root.clicked();
        }
    }
}
