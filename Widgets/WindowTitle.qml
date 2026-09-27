import QtQuick
import Quickshell
import Quickshell.Io
import qs.Utils
import qs
import qs.Common
import qs.Services

BarWidget {
    id: root
    readonly property string rawTitle: NiriService.focusedWindow?.title ?? ""
    readonly property string displayTitle: rawTitle.replace(/— Mozilla FireFox$/i, "");

    visible: displayTitle.length > 0
    readonly property int maxWidth: parent.parent.width / 3
    implicitWidth: label.unhoveredWidth + label.margin * 2
    clip: true
 
    ShellText {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        text: root.displayTitle
        readonly property int margin: 10
        readonly property real maxWidth: root.maxWidth - 2 * margin
        readonly property real unhoveredWidth: Math.min(implicitWidth, maxWidth)
        width: root.hovered ? undefined : unhoveredWidth
        elide: Qt.ElideRight
        color: ThemeManager.window
        onWidthChanged: if (!root.hovered) label.x = margin
        Marquee on x {
            distance: label.implicitWidth - label.maxWidth
            running: root.hovered && (label.implicitWidth > label.maxWidth)
            from: label.margin
        }

        NumberAnimation on x {
            id: returnAnim
            running: !root.hovered
            to: label.margin
            duration: Setting.animDuration
            easing.type: Easing.OutCubic
        }
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
