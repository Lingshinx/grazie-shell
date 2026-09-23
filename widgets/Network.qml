import QtQuick
import Quickshell
import Quickshell.Io
import "../common" as Common

Item {
    id: root

    property string connectionType: "disconnected" // "wifi" | "ethernet" | "disconnected"
    property string ifname: ""
    property int signalStrength: 0

    implicitWidth: networkBox.width
    implicitHeight: Common.ThemeManager.barHeight

    function getDisplayText() {
        if (root.connectionType === "wifi") {
            return `  ${root.signalStrength}%`;
        }
        if (root.connectionType === "ethernet") {
            return `  ${root.ifname}`;
        }
        return "⚠  Off";
    }

    Rectangle {
        id: networkBox
        width: networkText.implicitWidth + 20
        height: parent.height
        radius: height / 2
        color: Common.ThemeManager.background
        opacity: Common.ThemeManager.opacity

        Text {
            id: networkText
            anchors.centerIn: parent
            text: root.getDisplayText()
            font.family: "FiraCode Nerd Font Propo, FontAwesome, sans-serif"
            font.pixelSize: Common.ThemeManager.fontSize
            color: Common.ThemeManager.network
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: nmAppletProc.running = true

            onEntered: networkBox.opacity = 1.0
            onExited: networkBox.opacity = Common.ThemeManager.opacity
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Process {
        id: nmAppletProc
        command: ["bash", "-c", "~/.config/lingshin/scripts/waybar/nm-applet.sh"]
        running: false
    }

    Process {
        id: getNetworkProc
        command: ["bash", "-c", "nmcli -t -f TYPE,DEVICE,STATE connection show --active 2>/dev/null"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                let foundType = "disconnected";
                let foundDevice = "";

                // 优先检查以太网，其次 WiFi
                for (const line of lines) {
                    if (line.startsWith("802-3-ethernet:")) {
                        const parts = line.split(':');
                        foundType = "ethernet";
                        foundDevice = parts[1] || "eth0";
                        break;
                    } else if (line.startsWith("802-11-wireless:")) {
                        const parts = line.split(':');
                        foundType = "wifi";
                        foundDevice = parts[1] || "wlan0";
                    }
                }

                root.connectionType = foundType;
                root.ifname = foundDevice;

                if (foundType === "wifi") {
                    getSignalProc.running = true;
                }
            }
        }
    }

    Process {
        id: getSignalProc
        command: ["bash", "-c", "nmcli -t -f IN-USE,SIGNAL device wifi 2>/dev/null | grep '^\\*' | cut -d: -f2"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.signalStrength = parseInt(text.trim()) || 0;
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: getNetworkProc.running = true
    }

    Component.onCompleted: getNetworkProc.running = true
}
