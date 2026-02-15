import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BaseModal {
    id: root

    property var themes: []
    property string activeTheme: ""

    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"

    property int activeGroup: 0

    readonly property var groups: [
        { title: "Customization", icon: "assets/icons/settings.svg" },
        { title: "About", icon: "assets/icons/camera.svg" }
    ]

    signal requestTheme(string themePath)

    function themeLabel(themeItem) {
        if (themeItem && typeof themeItem === "object" && themeItem.name)
            return String(themeItem.name);
        const p = String(themeItem || "");
        const base = p.split("/").pop();
        return base.endsWith(".json") ? base.slice(0, -5) : base;
    }

    function themePath(themeItem) {
        if (themeItem && typeof themeItem === "object" && themeItem.path)
            return String(themeItem.path);
        return String(themeItem || "");
    }

    function titleCaseWords(s) {
        return String(s || "")
            .replace(/[-_]+/g, " ")
            .replace(/\s+/g, " ")
            .trim()
            .replace(/\b\w/g, c => c.toUpperCase());
    }

    function themeTitle(themeItem) {
        if (themeItem && typeof themeItem === "object" && themeItem.title)
            return String(themeItem.title);
        return titleCaseWords(themeLabel(themeItem));
    }

    function themeColor(themeItem, key, fallback) {
        if (themeItem && typeof themeItem === "object" && themeItem.colors && themeItem.colors[key])
            return themeItem.colors[key];
        return fallback;
    }

    function themeState(themeItem, key, fallback) {
        if (themeItem && typeof themeItem === "object" && themeItem.states && themeItem.states[key])
            return themeItem.states[key];
        return fallback;
    }

    function isActiveTheme(themeItem) {
        const p = themePath(themeItem);
        const a = String(root.activeTheme || "");
        if (p === a)
            return true;
        const name = p.split("/").pop();
        return a.endsWith("/" + name) || a === name;
    }

    card.width: Math.min(width - 170, 680)
    card.height: Math.min(height - 170, 450)
    card.anchors.centerIn: root
    card.radius: 14
    card.clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Settings"
                color: root.textPrimary
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "×"
                color: root.textSecondary
                font.pixelSize: 14

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closed()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Item {
                Layout.preferredWidth: 146
                Layout.fillHeight: true

                ListView {
                    anchors.fill: parent
                    model: root.groups
                    spacing: 2
                    clip: true

                    delegate: Item {
                        required property int index
                        required property var modelData
                        width: ListView.view.width
                        height: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: index === root.activeGroup ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 8

                            Image {
                                source: Qt.resolvedUrl("../" + String(modelData.icon))
                                sourceSize.width: 15
                                sourceSize.height: 15
                                Layout.leftMargin: 6
                            }

                            Text {
                                text: String(modelData.title)
                                color: index === root.activeGroup ? root.textPrimary : root.textSecondary
                                font.pixelSize: 13
                                font.weight: index === root.activeGroup ? Font.DemiBold : Font.Normal
                            }

                            Item { Layout.fillWidth: true }
                        }


                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeGroup = index
                        }
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.activeGroup

                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        Text {
                            text: "Theme"
                            color: root.textSecondary
                            font.pixelSize: 12
                        }

                        GridView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: root.themes
                            clip: true
                            cellWidth: Math.floor((width - 6) / 2)
                            cellHeight: 92

                            delegate: Rectangle {
                                required property var modelData
                                width: GridView.view.cellWidth - 8
                                height: GridView.view.cellHeight - 8
                                radius: 10
                                color: root.themeColor(modelData, "backgroundPanel", "#0A0A0A")
                                border.width: 0
                                border.color: "transparent"

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 7

                                    Row {
                                        spacing: 6

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 3
                                            color: root.themeColor(modelData, "backgroundCard", "#111111")
                                            border.width: 1
                                            border.color: root.themeColor(modelData, "border", "#1F1F1F")
                                        }

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: root.themeState(modelData, "toggleActiveBg", "#FFFFFF")
                                        }

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: root.themeState(modelData, "toggleInactiveBg", "#0B0B0B")
                                            border.width: 1
                                            border.color: root.themeColor(modelData, "border", "#1F1F1F")
                                        }

                                        Rectangle {
                                            width: 24
                                            height: 12
                                            radius: 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: root.themeState(modelData, "sliderTrack", "#1A1A1A")

                                            Rectangle {
                                                width: parent.width * 0.58
                                                height: parent.height
                                                radius: parent.radius
                                                color: root.themeState(modelData, "sliderFill", "#FFFFFF")
                                            }
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        text: root.themeTitle(modelData)
                                        color: root.themeColor(modelData, "textPrimary", root.textPrimary)
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                    }


                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: mouse => {
                                        mouse.accepted = true;
                                        root.requestTheme(root.themePath(modelData));
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 8

                        Text {
                            text: "About"
                            color: root.textPrimary
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Dropdeck"
                            color: root.textSecondary
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "License: Apache-2.0"
                            color: root.textSecondary
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Includes Material Icons SVGs (Apache-2.0)."
                            color: root.textSecondary
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
