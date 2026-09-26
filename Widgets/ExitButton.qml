import QtQuick
import Quickshell.Io
import qs.Common
import qs

ShellIcon {
    id: exitText
    text: ""
    anchors.verticalCenter: parent.verticalCenter

    opacity: opacity.value
    OpacityHover { id: opacity }
    Behavior on opacity {
        NumberAnimation { duration: Setting.animDuration}
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
