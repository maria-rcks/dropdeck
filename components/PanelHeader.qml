import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property date dateTime: new Date()
    property real batteryPercent: -1
    property real cpuPercent: 0
    property real memoryPercent: 0
    property real temperatureC: NaN

    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"

    Layout.fillWidth: true

    ColumnLayout {
        spacing: 2

        Text {
            text: {
                const t = Qt.formatTime(root.dateTime, "h:mm AP");
                const i = t.lastIndexOf(" ");
                if (i < 0)
                    return t;
                return t.slice(0, i) + " <span style='font-size:16px;'>" + t.slice(i + 1) + "</span>";
            }
            textFormat: Text.RichText
            color: root.textPrimary
            font.pixelSize: 34
            font.weight: Font.Light
        }

        Text {
            text: Qt.formatDate(root.dateTime, "ddd, MMM d")
            color: root.textSecondary
            font.pixelSize: 12
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
