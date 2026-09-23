import QtQuick
import Quickshell
import Quickshell.Io
import "../common"
import "../services" as Services

Rectangle {
    implicitHeight: exitText.implicitHeight
    implicitWidth: exitText.implicitWidth + 6

    color: "transparent"


    ShellIcon {
        id: exitText
        text: " "

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    wlogoutProc.running = !wlogoutProc.running;
                } else if (mouse.button === Qt.RightButton) {
                    Services.NiriService.action("closeOverview");
                }
            }

            onEntered: exitText.opacity = 1.0
            onExited: exitText.opacity = ThemeManager.opacity
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Process {
            id: wlogoutProc
            command: ["wlogout"]
            running: false
        }
    }
}
