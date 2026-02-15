import QtQuick

Rectangle {
    id: root

    property color scrimColor: "#000000aa"
    property color modalColor: "#060606"
    property real modalRadius: 18

    property bool cardGradientEnabled: false
    property color cardGradientStart: "#ffffff10"
    property color cardGradientEnd: "#00000010"
    property real cardGradientOpacity: 0.0

    property alias card: modalCard
    default property alias contentData: contentHost.data

    signal closed

    anchors.fill: parent
    color: root.scrimColor

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.closed()
    }

    Rectangle {
        id: modalCard
        radius: root.modalRadius
        color: root.modalColor

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: root.cardGradientEnabled && root.cardGradientOpacity > 0
            opacity: root.cardGradientOpacity
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.cardGradientStart }
                GradientStop { position: 1.0; color: root.cardGradientEnd }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: mouse => mouse.accepted = true
        }

        Item {
            id: contentHost
            anchors.fill: parent
        }
    }
}
