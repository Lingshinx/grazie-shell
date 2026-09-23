import QtQuick
import Quickshell
import Quickshell.Io
import "../common" as Common

Item {
    id: root

    property string time: Qt.formatDateTime(new Date(), "HH:mm - ddd")

    implicitWidth: clockBox.width
    implicitHeight: Common.ThemeManager.barHeight

    Rectangle {
        id: clockBox
        width: clockText.implicitWidth + 20
        height: parent.height
        radius: height / 2
        color: Common.ThemeManager.backgroundStress
        opacity: Common.ThemeManager.opacity
        border.color: Common.ThemeManager.border
        border.width: Common.ThemeManager.borderWidth

        Text {
            id: clockText
            anchors.centerIn: parent
            text: root.time
            font.family: Common.ThemeManager.fontFamily
            font.pixelSize: Common.ThemeManager.fontSize
            color: Common.ThemeManager.textlight
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: swayncProc.running = true

            onEntered: clockBox.opacity = 1.0
            onExited: clockBox.opacity = Common.ThemeManager.opacity
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.time = Qt.formatDateTime(new Date(), "HH:mm - ddd")
    }

    Process {
        id: swayncProc
        command: ["swaync-client", "-t"]
        running: false
    }

    Component.onCompleted: root.time = Qt.formatDateTime(new Date(), "HH:mm - ddd")
}
