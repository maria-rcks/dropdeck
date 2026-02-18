import QtQuick

Rectangle {
    id: root

    property var notification
    property color cardColor: "#0B0B0B"
    property color borderColor: "#1F1F1F"
    property color panelColor: "#1A1A1A"
    property color textPrimary: "#FFFFFF"
    property color textSecondary: "#A1A1AA"

    property bool cardGradientEnabled: false
    property color cardGradientStart: "#ffffff14"
    property color cardGradientEnd: "#00000014"
    property real cardGradientOpacity: 0.0

    property bool closing: false
    property real startX: 0

    readonly property string notificationSummary: root.notification && root.notification.summary ? root.notification.summary : "Notification"
    readonly property string notificationBody: root.notification && root.notification.body ? root.notification.body : ""
    readonly property string notificationApp: root.notification && root.notification.appName ? root.notification.appName : ""
    readonly property string notificationIcon: {
        if (!root.notification)
            return "";
        const candidates = [
            root.notification.image,
            root.notification.imagePath,
            root.notification.appIcon,
            root.notification.icon
        ];
        for (let i = 0; i < candidates.length; ++i) {
            const v = candidates[i];
            if (v !== undefined && v !== null && String(v).length > 0)
                return String(v);
        }
        return "";
    }

    radius: 14
    color: root.cardColor
    border.color: root.borderColor
    border.width: 1
    implicitHeight: popupCol.implicitHeight + 18
    x: 60
    opacity: 0

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

    function dismissCard() {
        if (root.closing)
            return;
        root.closing = true;
        closeAnim.start();
    }

    function activatePrimaryOrDismiss() {
        const actions = root.notification && root.notification.actions ? root.notification.actions : [];
        root.dismissCard();
        if (actions.length > 0 && actions[0] && actions[0].invoke)
            actions[0].invoke();
    }

    Component.onCompleted: enterAnim.start()

    SequentialAnimation {
        id: enterAnim
        ParallelAnimation {
            NumberAnimation { target: root; property: "x"; from: 60; to: 0; duration: 210; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutQuad }
        }
    }

    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation { target: root; property: "x"; to: root.width + 40; duration: 180; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "opacity"; to: 0; duration: 160; easing.type: Easing.InQuad }
        }
        ScriptAction {
            script: {
                if (root.notification && root.notification.dismiss)
                    root.notification.dismiss();
            }
        }
    }

    NumberAnimation {
        id: snapBack
        target: root
        property: "x"
        to: 0
        duration: 140
        easing.type: Easing.OutCubic
    }

    Timer {
        id: autoDismissTimer
        interval: 5200
        running: true
        repeat: false
        onTriggered: root.dismissCard()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        property bool dragged: false

        onPressed: mouse => {
            root.startX = mouse.x;
            dragged = false;
            autoDismissTimer.stop();
        }

        onPositionChanged: mouse => {
            if (!pressed)
                return;
            const dx = mouse.x - root.startX;
            if (Math.abs(dx) > 6)
                dragged = true;
            root.x = Math.max(0, dx);
            root.opacity = Math.max(0.2, 1 - root.x / (root.width * 1.2));
        }

        onReleased: {
            if (!dragged) {
                root.activatePrimaryOrDismiss();
                return;
            }

            if (root.x > root.width * 0.36)
                root.dismissCard();
            else {
                root.opacity = 1;
                snapBack.start();
                autoDismissTimer.restart();
            }
        }

        onEntered: autoDismissTimer.stop()
        onExited: {
            if (!root.closing)
                autoDismissTimer.restart();
        }
    }

    Column {
        id: popupCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 11
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7

        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: 28
                height: 28
                radius: 8
                color: root.panelColor
                visible: iconImage.status === Image.Ready

                Image {
                    id: iconImage
                    anchors.centerIn: parent
                    source: root.notificationIcon
                    sourceSize.width: 18
                    sourceSize.height: 18
                    asynchronous: true
                    cache: true
                }
            }

            Column {
                width: parent.width - (iconImage.status === Image.Ready ? 36 : 0)
                spacing: 2

                Text {
                    text: root.notificationSummary
                    color: root.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: root.notificationApp
                    color: "#71717A"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    visible: text.length > 0
                    width: parent.width
                }
            }
        }

        Text {
            text: root.notificationBody
            color: root.textSecondary
            font.pixelSize: 12
            wrapMode: Text.Wrap
            visible: text.length > 0
            width: parent.width
        }

        Row {
            spacing: 6
            visible: root.notification && root.notification.actions && root.notification.actions.length > 0

            Repeater {
                model: root.notification && root.notification.actions ? root.notification.actions : []

                delegate: Rectangle {
                    required property var modelData
                    radius: 10
                    color: root.panelColor
                    implicitWidth: popupActionLabel.implicitWidth + 14
                    implicitHeight: 24

                    Text {
                        id: popupActionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        color: root.textPrimary
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.dismissCard();
                            modelData.invoke();
                        }
                    }
                }
            }

        }
    }
}
