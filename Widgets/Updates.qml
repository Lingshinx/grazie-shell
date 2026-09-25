import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

BarWidget {
    id: root
    property string updateText: ""
    property string updateClass: "hidden"
    property int updateCount: 0
    implicitWidth: label.implicitWidth + 20

    visible: updateCount > 10

    color: updateClass > 200    ? ThemeManager.error
         : updateCount > 50 ? ThemeManager.warning
         : ThemeManager.background


    ShellText {
        id: label
        anchors.centerIn: parent
        text: `   ${root.updateCount}`
        color: root.updateCount > 50 ? ThemeManager.textlight : ThemeManager.text
    }

    onTapped: installUpdatesProc.running = true
    rightClickable: false

    Process {
        id: checkUpdatesProc
        command: ["checkupdates-with-aur"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.updateCount = parseInt(text.split("\n").length) - 1;
        }
    }

    Process {
        id: installUpdatesProc
        command: ["kitty", "--class", "floating", "-e", `${Quickshell.env("HOME")}/.config/lingshin/scripts/waybar/install-updates.sh`]
        running: false
        onExited: {
            checkUpdatesProc.running = true;
        }
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkUpdatesProc.running = true
    }
}
