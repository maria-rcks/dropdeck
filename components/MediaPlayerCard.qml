import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property string title: "Nothing playing"
    property string artist: ""
    property bool playing: false
    property string artUrl: ""

    property color cardColor: "#0A0A0A"
    property color borderColor: "#1F1F1F"
    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"

    property bool cardGradientEnabled: false
    property color cardGradientStart: "#ffffff10"
    property color cardGradientEnd: "#00000010"
    property real cardGradientOpacity: 0.0

    signal previousClicked
    signal playPauseClicked
    signal nextClicked

    radius: 22
    clip: true
    color: root.cardColor
    border.color: root.borderColor
    border.width: 1

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        visible: root.cardGradientEnabled && root.cardGradientOpacity > 0
        opacity: root.cardGradientOpacity
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.cardGradientStart }
            GradientStop { position: 1.0; color: root.cardGradientEnd }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 22
        clip: true
        color: "transparent"

        Rectangle {
            id: artMask
            anchors.fill: parent
            radius: 22
            visible: false
        }

        Image {
            id: playerArt
            anchors.fill: parent
            source: root.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            visible: root.artUrl.length > 0 && playerArt.status === Image.Ready
            opacity: 0.20
            layer.enabled: true
            layer.effect: OpacityMask { maskSource: artMask }
        }

        Rectangle {
            anchors.fill: parent
            radius: 22
            visible: root.artUrl.length > 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.alpha(root.cardColor, 0.18) }
                GradientStop { position: 1.0; color: Qt.alpha(root.cardColor, 0.90) }
            }
        }

    }

    Item {
        anchors.fill: parent
        anchors.margins: 12

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 2

            Text {
                text: root.title
                color: root.textPrimary
                font.pixelSize: 18
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: root.artist.length > 0 ? root.artist : ""
                color: root.textSecondary
                font.pixelSize: 12
                elide: Text.ElideRight
                width: parent.width
                visible: text.length > 0
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            spacing: 4

            Row {
                spacing: 16
                height: 34
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    width: 26
                    height: 26
                    y: 4

                    Image {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 1
                        source: Qt.resolvedUrl("../assets/icons/skip_prev.svg")
                        sourceSize.width: 20
                        sourceSize.height: 20
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.previousClicked()
                    }
                }

                Item {
                    width: 34
                    height: 34

                    Image {
                        anchors.centerIn: parent
                        source: root.playing ? Qt.resolvedUrl("../assets/icons/pause.svg") : Qt.resolvedUrl("../assets/icons/play.svg")
                        sourceSize.width: 28
                        sourceSize.height: 28
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.playPauseClicked()
                    }
                }

                Item {
                    width: 26
                    height: 26
                    y: 4

                    Image {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -1
                        source: Qt.resolvedUrl("../assets/icons/skip_next.svg")
                        sourceSize.width: 20
                        sourceSize.height: 20
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nextClicked()
                    }
                }
            }

        }
    }
}
