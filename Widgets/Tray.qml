pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs
import qs.Common

Row {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    spacing: 10

    required property ShellScreen screen
    readonly property var items: SystemTray.items.values
    property var currentTrayItem: null
    visible: items.length > 0

    Loader {
        id: loader
        readonly property TrayMenu menuItem: item as TrayMenu
        active: root.currentTrayItem?.modelData?.hasMenu ?? false
        sourceComponent: menu
        asynchronous: true
        visible: status == Loader.Ready
    }

    Component {
        id: menu
        TrayMenu {
            screen: root.screen
            trayIcon: root.currentTrayItem
            onMenuClosed: root.currentTrayItem = null
        }
    }

    Repeater {
        model: ScriptModel {
            values: root.items
            objectProp: "key"
        }
        IconImage {
            id: icon
            required property SystemTrayItem modelData
            required property int index
            width: 21
            height: 21
            source: modelData.icon
            asynchronous: true

            opacity: opacity.value
            OpacityHover { id: opacity }
            Behavior on opacity {
                NumberAnimation { duration: Setting.animDuration }
            }

            TapHandler {
                onTapped: icon.modelData.activate()
            }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: if (icon.modelData.hasMenu) {
                    if (root.currentTrayItem != icon) {
                        root.currentTrayItem = icon;
                    } else {
                        loader.menuItem.showMenu = false
                    }
                }
            }
        }
    }
}
