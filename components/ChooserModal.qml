import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BaseModal {
    id: root

    property string title: ""
    property var items: []
    property bool powerStyle: false

    property color sectionColor: "#101010"
    property color activeColor: "#FFFFFF"
    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"
    property color textMuted: "#71717A"

    signal selected(var item)

    card.width: root.powerStyle ? Math.min(width - 80, 560) : Math.min(width - 120, 460)
    card.height: root.powerStyle
        ? 190
        : Math.min(Math.max(190, 88 + Math.min(root.items.length, 6) * 58), Math.min(height - 220, 430))
    card.anchors.centerIn: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.title
                color: root.textPrimary
                font.pixelSize: 16
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

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

        Item {
            id: powerContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.powerStyle

            property int actionCount: Math.max(1, root.items.length)
            property real powerSpacing: 14
            property real powerTileWidth: Math.max(70, Math.min(90, Math.floor((width - 24 - (actionCount - 1) * powerSpacing) / actionCount)))

            Row {
                anchors.centerIn: parent
                spacing: powerContainer.powerSpacing

                Repeater {
                    model: root.items

                    delegate: Item {
                        required property var modelData
                        width: powerContainer.powerTileWidth
                        height: powerContainer.height - 8

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: {
                                    const s = String(modelData.icon || "");
                                    return s.startsWith("assets/") ? Qt.resolvedUrl("../" + s) : s;
                                }
                                sourceSize.width: 34
                                sourceSize.height: 34
                                visible: String(source).length > 0
                                opacity: modelData.disabled ? 0.45 : 1.0
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.title || ""
                                color: modelData.disabled ? root.textMuted : root.textPrimary
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: modelData.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: {
                                if (!modelData.disabled)
                                    root.selected(modelData);
                            }
                        }
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: !root.powerStyle

            Item {
                width: parent.width
                implicitHeight: listColumn.implicitHeight

                Column {
                    id: listColumn
                    width: parent.width
                    spacing: 7

                    Repeater {
                        model: root.items

                        delegate: Rectangle {
                            required property var modelData
                            width: parent.width
                            radius: 12
                            color: modelData.disabled ? Qt.rgba(1, 1, 1, 0.03) : (modelData.active ? root.activeColor : root.sectionColor)
                            implicitHeight: 54

                            Column {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 11
                                spacing: 2

                                Text {
                                    text: modelData.title || ""
                                    color: modelData.disabled ? root.textMuted : (modelData.active ? "#000000" : root.textPrimary)
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: modelData.subtitle || ""
                                    color: modelData.disabled ? root.textMuted : (modelData.active ? "#1A1A1A" : root.textSecondary)
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    visible: text.length > 0
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: modelData.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: {
                                    if (!modelData.disabled)
                                        root.selected(modelData);
                                }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 40
                    visible: root.items.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: "No items found"
                        color: root.textMuted
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
