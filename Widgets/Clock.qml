import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Item {
    id: root

    property string time: Qt.formatDateTime(new Date(), "HH:mm - ddd")

    implicitWidth: clockBox.width
    implicitHeight: ThemeManager.barHeight

    Rectangle {
        id: clockBox
        width: clockText.implicitWidth + 20
        height: parent.height
        radius: height / 2
        color: ThemeManager.backgroundStress
        opacity: ThemeManager.opacity
        border.color: ThemeManager.border
        border.width: ThemeManager.borderWidth

        Text {
            id: clockText
            anchors.centerIn: parent
            text: root.time
            font.family: ThemeManager.fontFamily
            font.pixelSize: ThemeManager.fontSize
            color: ThemeManager.textlight
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: swayncProc.running = true

            onEntered: clockBox.opacity = 1.0
            onExited: clockBox.opacity = ThemeManager.opacity
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
