import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BaseModal {
    id: root

    property date currentDate: new Date()
    property int displayMonth: currentDate.getMonth()
    property int displayYear: currentDate.getFullYear()

    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"
    property color textMuted: "#6B7280"
    property color activeDayBg: "#FFFFFF"
    property color activeDayFg: "#000000"

    readonly property int todayDay: currentDate.getDate()
    readonly property int todayMonth: currentDate.getMonth()
    readonly property int todayYear: currentDate.getFullYear()

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstWeekday(year, month) {
        return (new Date(year, month, 1).getDay() + 6) % 7;
    }

    function monthName(month) {
        const names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        return names[month] || "";
    }

    function prevMonth() {
        if (displayMonth === 0) {
            displayMonth = 11;
            displayYear -= 1;
        } else {
            displayMonth -= 1;
        }
    }

    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0;
            displayYear += 1;
        } else {
            displayMonth += 1;
        }
    }

    card.width: Math.min(width - 80, 340)
    card.height: Math.min(height - 120, 360)
    card.anchors.centerIn: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Item {
                implicitWidth: 24
                implicitHeight: 24

                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: root.textPrimary
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevMonth()
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.monthName(root.displayMonth) + " " + root.displayYear
                color: root.textPrimary
                font.pixelSize: 16
                font.weight: Font.Medium
            }

            Item {
                implicitWidth: 24
                implicitHeight: 24

                Text {
                    anchors.centerIn: parent
                    text: "›"
                    color: root.textPrimary
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextMonth()
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

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 4
            columnSpacing: 0

            Repeater {
                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                delegate: Text {
                    required property string modelData
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: root.textMuted
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rowSpacing: 4
            columnSpacing: 0

            Repeater {
                model: 42

                delegate: Item {
                    required property int index

                    property int first: root.firstWeekday(root.displayYear, root.displayMonth)
                    property int days: root.daysInMonth(root.displayYear, root.displayMonth)
                    property int dayNum: index - first + 1
                    property bool inMonth: dayNum >= 1 && dayNum <= days
                    property bool isToday: inMonth
                                          && dayNum === root.todayDay
                                          && root.displayMonth === root.todayMonth
                                          && root.displayYear === root.todayYear

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: 34

                    Rectangle {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        radius: 13
                        color: isToday ? root.activeDayBg : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: inMonth ? String(dayNum) : ""
                        color: isToday ? root.activeDayFg : root.textPrimary
                        font.pixelSize: 13
                        font.weight: isToday ? Font.DemiBold : Font.Normal
                    }
                }
            }
        }
    }
}
