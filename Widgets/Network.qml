import QtQuick
import Quickshell.Networking
import qs.Common
import qs.Utils
import qs.Services

BarWidget {
    implicitWidth: label.implicitWidth + 20
    ShellText {
        id: label
        anchors.centerIn: parent
        readonly property string status: NetworkService.status
        readonly property int signalStrength: 0
        readonly property string wifiIcon
            : signalStrength > 75 ? "󰤨 "
            : signalStrength > 50 ? "󰤥 "
            : signalStrength > 25 ? "󰤢 "
            : "󰤟 "

        color: status == "disconnected" ? ThemeManager.warning : ThemeManager.network
        readonly property string icon
            : status === "wifi" ? wifiIcon
            : status === "ethernet" ? " "
            : " "

        readonly property string name
            : status === "wifi" ? NetworkService.currentSSID
            : status === "ethernet" ? NetworkService.wiredDevice?.name ?? ""
            : "Off"

        function format(rate) {
            return Utils.formatBytes(rate, 0).padStart(9, ' ')
        }

        text: `${icon}  ${name}`

        NetworkRater {
            id: rater
            enabled: NetworkService.status !== "disconnected"
            interfaceName: NetworkService.currentDevice?.name ?? ""
        }
    }
}
