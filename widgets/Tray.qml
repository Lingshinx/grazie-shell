import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../common" as Common

Item {
    id: root

    readonly property var items: SystemTray.items.values
    visible: items.length > 0

    implicitWidth: visible ? trayRow.implicitWidth : 0
    implicitHeight: Common.ThemeManager.barHeight

    Row {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Repeater {
            model: root.items
            delegate: Item {
                id: trayItemDelegate
                required property var modelData
                required property int index

                width: 21
                height: 21
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    id: trayIcon
                    anchors.fill: parent
                    source: trayItemDelegate.modelData.icon
                    asynchronous: true
                    opacity: trayMouseArea.containsMouse ? 1.0 : Common.ThemeManager.opacity

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                }

                MouseArea {
                    id: trayMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            trayItemDelegate.modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            trayItemDelegate.modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
