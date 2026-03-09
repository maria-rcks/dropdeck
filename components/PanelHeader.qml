import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property date dateTime: new Date()
    property string timeText: ""
    property string dateText: ""
    property string clockLabel: ""
    property bool clockClickable: false
    property real batteryPercent: -1
    property real cpuPercent: 0
    property real memoryPercent: 0
    property real temperatureC: NaN

    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"

    signal clockClicked()

    function normalizedTimeText() {
        const fallback = Qt.formatTime(root.dateTime, "hh:mm AP");
        const raw = String(root.timeText || "").length > 0 ? String(root.timeText).trim() : fallback;
        return raw.replace(/^(\d):/, "0$1:");
    }

    function formattedTimeMarkup() {
        const raw = root.normalizedTimeText();
        const i = raw.lastIndexOf(" ");
        if (i < 0)
            return raw;
        return raw.slice(0, i) + " <span style='font-size:16px;'>" + raw.slice(i + 1) + "</span>";
    }

    function formattedDateText() {
        return String(root.dateText || "").length > 0 ? String(root.dateText) : Qt.formatDate(root.dateTime, "ddd, MMM d");
    }

    Layout.fillWidth: true

    Rectangle {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        Layout.preferredWidth: clockColumn.implicitWidth + 16
        Layout.preferredHeight: clockColumn.implicitHeight + 10
        radius: 14
        color: "transparent"
        border.width: 0
        border.color: Qt.rgba(1, 1, 1, 0.08)

        ColumnLayout {
            id: clockColumn
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            spacing: 2

            Text {
                id: timeDisplay
                text: root.formattedTimeMarkup()
                textFormat: Text.RichText
                color: root.textPrimary
                font.pixelSize: 34
                font.weight: Font.Light
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: timeDisplay.implicitWidth
                spacing: 4

                Text {
                    text: root.formattedDateText()
                    color: root.textSecondary
                    font.pixelSize: 12
                }

                Item {
                    visible: String(root.clockLabel || "").trim().length > 0
                    Layout.fillWidth: true
                }

                Text {
                    visible: String(root.clockLabel || "").trim().length > 0
                    text: String(root.clockLabel || "").trim()
                    color: root.textSecondary
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        MouseArea {
            id: clockArea
            anchors.fill: parent
            enabled: root.clockClickable
            hoverEnabled: root.clockClickable
            cursorShape: root.clockClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.clockClicked()
        }
    }

    Item { Layout.fillWidth: true }

    ColumnLayout {
        spacing: 4
        Layout.alignment: Qt.AlignVCenter

        Text {
            text: root.batteryPercent >= 0 ? (Math.round(root.batteryPercent) + "%") : "--%"
            color: root.textPrimary
            font.pixelSize: 34
            font.weight: Font.Light
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight
        }

        Text {
            text: "CPU " + Math.round(root.cpuPercent) + "% · RAM " + Math.round(root.memoryPercent) + "%" + (isFinite(root.temperatureC) ? (" · " + root.temperatureC.toFixed(0) + "°C") : "")
            color: root.textSecondary
            font.pixelSize: 11
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight
        }

    }
}
