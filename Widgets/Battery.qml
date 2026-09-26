import QtQuick
import Quickshell.Services.UPower
import qs.Common
import qs

Item {
    id: root

    readonly property var laptopBatteries: UPower.devices.values.filter(d => d.isLaptopBattery)
    readonly property UPowerDevice batteryDevice: laptopBatteries[0] || null

    readonly property bool hasBattery: batteryDevice !== null
    readonly property int capacity: batteryDevice ? Math.round(batteryDevice.percentage * 100) : 0
    readonly property bool isCharging: batteryDevice ? (batteryDevice.state === UPowerDeviceState.Charging) : false
    readonly property bool isPlugged: !UPower.onBattery
    readonly property bool isCritical: hasBattery && capacity <= 15 && !isCharging && !isPlugged

    visible: hasBattery
    implicitWidth: visible ? batteryBox.width : 0
    implicitHeight: ThemeManager.barHeight

    function getBatteryIcon() {
        if (root.isCharging) return "";
        if (root.isPlugged) return "";
        if (root.capacity <= 20) return "";
        if (root.capacity <= 40) return "";
        if (root.capacity <= 60) return "";
        if (root.capacity <= 80) return "";
        return "";
    }

    Rectangle {
        id: batteryBox
        width: batteryRow.implicitWidth + 20
        height: parent.height
        radius: height / 2
        color: (root.isCritical && blinkTimer.blinkState) ? ThemeManager.warning : ThemeManager.background
        opacity: ThemeManager.opacity

        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.getBatteryIcon()
                font.family: "FiraCode Nerd Font Propo, FontAwesome, sans-serif"
                font.pixelSize: ThemeManager.fontSize
                color: ThemeManager.text
            }

            Text {
                text: root.capacity + "%"
                font.family: ThemeManager.fontFamily
                font.pixelSize: ThemeManager.fontSize
                color: ThemeManager.text
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: batteryBox.opacity = 1.0
            onExited: batteryBox.opacity = ThemeManager.opacity
        }

        Behavior on opacity {
            NumberAnimation { duration: Setting.animDuration }
        }
    }

    Timer {
        id: blinkTimer
        interval: 500
        running: root.isCritical
        repeat: true
        property bool blinkState: false
        onTriggered: blinkState = !blinkState
    }
}
