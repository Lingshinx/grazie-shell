import QtQuick
import Quickshell
import Quickshell.Io
import "../common" as Common

Item {
    id: root

    property int cpuUsage: 0
    property real memoryUsed: 0.0
    property int diskUsage: 0
    property int temperature: 0

    property bool isExpanded: false

    function getTempIcon() {
        if (root.temperature >= 75) return "";
        if (root.temperature >= 60) return "";
        if (root.temperature >= 45) return "";
        return "";
    }

    implicitWidth: hardwareBox.width
    implicitHeight: Common.ThemeManager.barHeight

    Rectangle {
        id: hardwareBox
        height: parent.height
        radius: height / 2
        color: Common.ThemeManager.background
        opacity: Common.ThemeManager.opacity
        clip: true

        width: handleIconBox.width + (root.isExpanded ? drawerContent.width + 10 : 0)

        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: 0

            Item {
                id: handleIconBox
                width: 32
                height: Common.ThemeManager.barHeight

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "FiraCode Nerd Font Propo, FontAwesome, sans-serif"
                    font.pixelSize: 18
                    font.bold: true
                    color: Common.ThemeManager.iconColor
                }
            }

            Item {
                id: drawerContent
                height: Common.ThemeManager.barHeight
                width: root.isExpanded ? childrenRow.implicitWidth : 0
                opacity: root.isExpanded ? 1.0 : 0.0
                clip: true

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }

                Row {
                    id: childrenRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Text {
                        text: " " + root.diskUsage + "%"
                        font.family: Common.ThemeManager.fontFamily
                        font.pixelSize: Common.ThemeManager.fontSize
                        color: Common.ThemeManager.iconColor
                    }

                    Text {
                        text: " " + root.cpuUsage + "%"
                        font.family: Common.ThemeManager.fontFamily
                        font.pixelSize: Common.ThemeManager.fontSize
                        color: Common.ThemeManager.iconColor
                    }

                    Text {
                        text: "M " + root.memoryUsed.toFixed(2) + "G"
                        font.family: Common.ThemeManager.fontFamily
                        font.pixelSize: Common.ThemeManager.fontSize
                        color: Common.ThemeManager.iconColor
                    }

                    Text {
                        text: root.getTempIcon() + " " + root.temperature + "°C"
                        font.family: Common.ThemeManager.fontFamily
                        font.pixelSize: Common.ThemeManager.fontSize
                        color: root.temperature >= 80 ? Common.ThemeManager.error : Common.ThemeManager.iconColor
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                root.isExpanded = true;
                hardwareBox.opacity = 1.0;
            }

            onExited: {
                root.isExpanded = false;
                hardwareBox.opacity = Common.ThemeManager.opacity;
            }

            onClicked: root.isExpanded = !root.isExpanded
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Process {
        id: getHardwareStatsProc
        command: ["bash", "-c", "cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d. -f1); mem=$(free -m | awk 'NR==2{printf \"%.2f\", $3/1024}'); disk=$(df -h / | awk 'NR==2{print $5}' | tr -d '%'); temp=$(cat /sys/class/hwmon/hwmon5/temp1_input 2>/dev/null || echo 0); temp=$((temp / 1000)); echo \"$cpu|$mem|$disk|$temp\""]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split('|');
                if (parts.length >= 4) {
                    root.cpuUsage = parseInt(parts[0]) || 0;
                    root.memoryUsed = parseFloat(parts[1]) || 0.0;
                    root.diskUsage = parseInt(parts[2]) || 0;
                    root.temperature = parseInt(parts[3]) || 0;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: getHardwareStatsProc.running = true
    }

    Component.onCompleted: getHardwareStatsProc.running = true
}
