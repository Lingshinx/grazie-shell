import QtQuick
import Quickshell.Io
import qs.Common

ShellIcon {
    id: exitText
    text: ""
    anchors.verticalCenter: parent.verticalCenter

    opacity: opacity.value
    OpacityHover { id: opacity }
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    TapHandler {
        onTapped: wlogoutProc.running = !wlogoutProc.running;
    }

    Process {
        id: wlogoutProc
        command: ["wlogout"]
        running: false
    }
}
