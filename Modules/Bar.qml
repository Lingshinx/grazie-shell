import QtQuick
import Quickshell
import qs.Widgets

Variants {
    property var enabledMonitors: ["DP-2"]
    model: Quickshell.screens.filter(s => enabledMonitors.includes(s.name))

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 10
            left: 14
            right: 14
        }

        implicitHeight: Math.max(
          leftRow.implicitHeight,
          centerWidget.implicitHeight,
          rightRow.implicitHeight
        )

        color: "transparent"

        Row {
            id: leftRow
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            ArchLogo {}
            Wallpaper {}
            WindowTitle {}
        }

        Workspaces {
            id: centerWidget
            screenName: bar.screen.name
            anchors.centerIn: parent
        }

        Row {
            id: rightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            Updates {}
            Audio {}
            Battery {}
            Network {}
            Hardware {}
            Tray {}
            ExitButton {}
            Clock {}
        }
    }
}
