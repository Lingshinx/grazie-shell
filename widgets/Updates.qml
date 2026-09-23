import QtQuick
import Quickshell.Io
import "../common"

Rectangle {
    id: root
    property string updateText: ""
    property string updateClass: "hidden"
    property int updateCount: 0

    // visible: updateClass !== "hidden" && updateCount > 0

    implicitWidth: label.implicitWidth + 20
    implicitHeight: ThemeManager.barHeight
    radius: height / 2
    opacity: hoverHandler.hovered ? 1.0 : ThemeManager.opacity

    color: updateClass === "red"    ? ThemeManager.error
         : updateClass === "yellow" ? ThemeManager.warning
         : ThemeManager.background


    ShellText {
        id: label
        anchors.centerIn: parent
        text: "   2" + root.updateCount.toString()
        color: root.updateClass === "red" || root.updateClass === "yellow"
             ? ThemeManager.textlight : ThemeManager.text
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: installUpdatesProc.running = true
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Process {
        id: checkUpdatesProc
        command: ["~/.config/lingshin/scripts/waybar/check-updates.sh"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim());
                    root.updateClass = data.class || "hidden";
                    root.updateCount = parseInt(data.alt) || 0;
                    root.updateText = data.text || "";
                } catch (e) {
                    root.updateClass = "hidden";
                    root.updateCount = 0;
                }
            }
        }
    }

    Process {
        id: installUpdatesProc
        command: ["kitty", "--class", "floating", "-e", "~/.config/lingshin/scripts/waybar/install-updates.sh"]
        running: false
        onExited: {
            // 更新完成后重新检测
            checkUpdatesProc.running = true;
        }
    }

    Timer {
        interval: 1800000 // 30 分钟
        running: true
        repeat: true
        onTriggered: checkUpdatesProc.running = true
    }
}
