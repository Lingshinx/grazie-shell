import QtQuick
import Quickshell.Io
import "../common"
import "../services"

Rectangle {
    id: root
    readonly property string rawTitle: NiriService.focusedWindow?.title ?? ""
    readonly property string displayTitle: rawTitle.replace(/— Mozilla FireFox$/i, "");

    visible: displayTitle.length > 0
    implicitWidth: windowText.implicitWidth + 20
    implicitHeight: ThemeManager.barHeight
    anchors.verticalCenter: parent.verticalCenter
    radius: height / 2
    color: ThemeManager.background
    opacity: opacity.value

    OpacityHover {
        id: opacity
    }

    ShellText {
        id: windowText
        anchors.centerIn: parent
        text: root.displayTitle
        color: ThemeManager.window
    }

    TapHandler {
        onTapped: rofiProc.running = !rofiProc.running
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: kittyProc.running = !kittyProc.running
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

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
