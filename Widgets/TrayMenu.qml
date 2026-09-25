pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.Utils
import qs.Common

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    property var trayIcon: null
    property bool showMenu: false
    property bool firstOpen: false
    readonly property var trayData: trayIcon.modelData
    readonly property var trayMenu: trayData.menu
    signal menuClosed()

    visible: showMenu || menuContainer.opacity > 0
    color: "transparent"

    onTrayIconChanged: {
        if (showMenu) firstOpen = true; else firstOpen = false
        showMenu = true
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    onVisibleChanged: {
        if (!visible) menuClosed()
    }

    TapHandler {
        onTapped: root.showMenu = false
    }

    Rectangle {
        id: menuContainer
        color: ThemeManager.background
        radius: ThemeManager.borderRadius
        border.color: ThemeManager.border
        border.width: 1
        clip: true

        visible: opener.children.values.length > 0
        opacity: visible && root.showMenu ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Setting.animDuration } }

        property var delayedModel: []
        property int targetWidth: menuColumn.implicitWidth + 16
        property int targetHeight: menuColumn.implicitHeight + 16
        property int targetX: {
            const leftLimit = Setting.bar.margins.left
            const rightLimit = root.width - targetWidth - Setting.bar.margins.right
            const x = root.trayIcon.mapToItem(null, 0, 0).x + Setting.bar.margins.left + root.trayIcon.width / 2 - targetWidth / 2
            return Math.max(leftLimit, Math.min(rightLimit, x))
        }

        function syncTarget() {
            width = targetWidth
            height = targetHeight
            x = targetX
        }

        QsMenuOpener {
            id: opener
            menu: root.trayMenu
            onChildrenChanged: if (menuContainer.visible && menuColumn.opacity > 0) {
                updateAnim.restart()
            } else {
                menuContainer.delayedModel = children
            }
        }

        SequentialAnimation {
            id: updateAnim
            property int animDuration: Setting.animDuration
            NumberAnimation {
                target: menuColumn
                property: "opacity"
                to: 0
                duration: Setting.animDuration
                easing.type: Easing.OutQuad
            }
            ScriptAction { script: menuContainer.delayedModel = opener.children }
            PauseAnimation { duration: 10 }
            ParallelAnimation {
                NumberAnimation {
                    target: menuContainer
                    property: "width"; to: menuContainer.targetWidth
                    duration: updateAnim.animDuration
                }
                NumberAnimation {
                    target: menuContainer
                    property: "height"; to: menuContainer.targetHeight
                    duration: updateAnim.animDuration
                }
                NumberAnimation {
                    target: menuContainer
                    property: "x"; to: menuContainer.targetX
                    duration: Setting.animDuration
                }
            }
            NumberAnimation {
                target: menuColumn
                property: "opacity"; to: 1
                duration: updateAnim.animDuration
            }
        }

        ColumnLayout {
            id: menuColumn
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: menuContainer.delayedModel
                Rectangle {
                    id: menuItem
                    required property var modelData
                    required property int index
                    readonly property var entry: modelData
                    readonly property int maxWidth: 200
                    Layout.fillWidth: true
                    Layout.maximumWidth: maxWidth
                    Layout.preferredWidth: label.implicitWidth + label.margin * 2
                    height: entry.isSeparator ? 1 : 24
                    radius: height / 2
                    color: entry.isSeparator ? ThemeManager.workspaces
                         : hover.hovered     ? Qt.lighter(ThemeManager.backgroundStress, 1.2)
                         : "transparent"
                    clip: true

                    Behavior on color { ColorAnimation { duration: Setting.animDuration } }
                    HoverHandler { id: hover }

                    TapHandler {
                        onTapped: {
                            if (menuItem.entry.activate) menuItem.entry.activate();
                            else if (menuItem.entry.triggered) menuItem.entry.triggered();
                            root.showMenu = false
                        }
                    }

                    Text {
                        id: label

                        anchors.verticalCenter: parent.verticalCenter
                        text: menuItem.entry.text ?? ""
                        font.pixelSize: 12
                        color: ThemeManager.text

                        readonly property int margin: 8
                        readonly property int maxWidth: menuItem.maxWidth - margin * 2
                        x: margin
                        width: hover.hovered ? undefined : maxWidth
                        elide: hover.hovered ? Text.ElideNone : Text.ElideRight

                        Marquee on x {
                            distance: label.implicitWidth - label.maxWidth
                            running: hover.hovered && (label.implicitWidth > label.maxWidth)
                            from: label.margin
                        }

                        NumberAnimation on x {
                            id: returnAnim
                            running: !hover.hovered
                            to: label.margin
                            duration: Setting.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }

                }
            }
        }
    }
}
