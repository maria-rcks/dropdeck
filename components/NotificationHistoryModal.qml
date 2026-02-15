import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BaseModal {
    id: root

    property var notifications: []

    property color sectionColor: "#101010"
    property color sectionAltColor: "#181818"
    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"
    property color textMuted: "#71717A"

    signal clearAllRequested

    card.width: Math.min(width - 110, 520)
    card.height: root.notifications.length > 0
        ? Math.min(maxHeight, chromeHeight + Math.max(84, notificationColumn.implicitHeight))
        : 170
    card.anchors.centerIn: root

    readonly property real padding: 12
    readonly property real headerHeight: 24
    readonly property real gap: 8
    readonly property real maxHeight: Math.min(height - 120, 600)
    readonly property real chromeHeight: (padding * 2) + headerHeight + gap
    readonly property real listMaxHeight: maxHeight - chromeHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.gap

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight

            Text {
                text: "Notifications"
                color: root.textPrimary
                font.pixelSize: 16
                font.weight: Font.Medium
            }

            Text {
                text: String(root.notifications.length)
                color: root.textMuted
                font.pixelSize: 12
            }

            Item { Layout.fillWidth: true }

            Text {
                visible: root.notifications.length > 0
                text: "Clear all"
                color: root.textSecondary
                font.pixelSize: 11

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.clearAllRequested()
                }
            }

            Item {
                implicitWidth: 24
                implicitHeight: 24

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: root.textSecondary
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closed()
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(root.listMaxHeight, Math.max(84, notificationColumn.implicitHeight))
            clip: true
            visible: root.notifications.length > 0

            Column {
                id: notificationColumn
                width: parent.width
                spacing: 7

                Repeater {
                    model: root.notifications

                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width
                        radius: 12
                        color: root.sectionColor
                        implicitHeight: contentCol.implicitHeight + 16

                        Column {
                            id: contentCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 10
                            spacing: 6

                            Text {
                                text: modelData.summary || "Notification"
                                color: root.textPrimary
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                wrapMode: Text.Wrap
                            }

                            Text {
                                text: modelData.body || ""
                                color: root.textSecondary
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                                visible: text.length > 0
                            }

                            Row {
                                spacing: 6
                                visible: modelData.actions && modelData.actions.length > 0

                                Repeater {
                                    model: modelData.actions

                                    delegate: Rectangle {
                                        required property var modelData
                                        radius: 10
                                        color: root.sectionAltColor
                                        implicitWidth: actionLabel.implicitWidth + 14
                                        implicitHeight: 24

                                        Text {
                                            id: actionLabel
                                            anchors.centerIn: parent
                                            text: modelData.text
                                            color: root.textPrimary
                                            font.pixelSize: 11
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.notifications.length === 0

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "🔔"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0.6
                }
                Text {
                    text: "No notifications"
                    color: root.textSecondary
                    font.pixelSize: 13
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
