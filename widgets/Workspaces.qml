pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../common"
import "../services"

Rectangle {
    id: root

    required property string screenName
    readonly property var workspaceIcons: ({
        1: "",
        2: "",
        3: "",
        4: "",
        "default": "",
        "urgent": ""
    })

    radius: height / 2
    implicitHeight: row.implicitHeight + 8
    implicitWidth: row.implicitWidth + 8
    color: Qt.alpha(ThemeManager.workspaces, ThemeManager.opacity)

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onWheel: event => {
            const isUp = event.angleDelta.y > 0
            const action = event.buttons & Qt.MiddleButton
                ? (isUp ? "FocusWorkspaceUp" : "FocusWorkspaceDown")
                : (isUp ? "FocusColumnLeft" : "FocusColumnRight")
            NiriService.action(action)
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: ScriptModel {
                objectProp: "id"
                values: NiriService.workspaces[root.screenName] ?? []
            }
            delegate: Rectangle {
                id: button
                required property var modelData
                required property int index

                readonly property bool isActive: modelData.is_active
                readonly property bool isFocused: modelData.is_focused
                readonly property bool isUrgent: modelData.is_urgent
                property real alpha: hoverHandler.hovered ? 0.7
                                   : isActive ? 1.0
                                   : 0.4

                implicitHeight: ThemeManager.barHeight - 2
                implicitWidth: isFocused ? 50 : implicitHeight
                radius: height / 2

                color: Qt.alpha(isUrgent ? ThemeManager.workspacesUrgent : ThemeManager.workspacesButton, alpha)

                ShellIcon {
                    anchors.fill: parent
                    font.pixelSize: ThemeManager.fontSize
                    text: button.isUrgent ? root.workspaceIcons.urgent :
                        root.workspaceIcons[button.modelData.idx] ?? root.workspaceIcons.default
                    color: button.isUrgent ? ThemeManager.textlight : ThemeManager.workspaces
                }

                TapHandler {
                    onTapped: NiriService.focusWorkspaceById(button.modelData.id)
                }

                HoverHandler {
                    id: hoverHandler
                    cursorShape: Qt.PointingHandCursor
                }

                Behavior on implicitWidth {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                Behavior on alpha {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
