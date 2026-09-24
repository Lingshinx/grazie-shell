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
    implicitWidth: label.implicitWidth + 20
 
    ShellText {
        id: label
        anchors.centerIn: parent
        text: root.displayTitle
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
