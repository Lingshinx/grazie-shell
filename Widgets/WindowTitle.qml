import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

BarWidget {
    id: root
    readonly property string rawTitle: NiriService.focusedWindow?.title ?? ""
    readonly property string displayTitle: rawTitle.replace(/— Mozilla FireFox$/i, "");

    visible: displayTitle.length > 0
    implicitWidth: Math.min(label.implicitWidth + 20, parent.parent.width / 3)
 
    ShellText {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: root.displayTitle
        width: parent.width - 20
        elide: Qt.ElideRight
        color: ThemeManager.window
    }

    onTapped: rofiProc.running = !rofiProc.running
    onRightTapped: kittyProc.running = !kittyProc.running

    Process {
        id: rofiProc
        command: [`${Quickshell.env("HOME")}/.config/lingshin/scripts/rofi/launch.sh`, "drawer"]
        running: false
    }

    Process {
        id: kittyProc
        command: ["kitty"]
        running: false
    }
}
