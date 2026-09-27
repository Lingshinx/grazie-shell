import QtQuick
import qs.Common
import qs

Rectangle {
    id: root
    signal tapped()
    signal rightTapped()
    property bool clickable: true
    property bool rightClickable: true
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: ThemeManager.barHeight
    color: ThemeManager.background
    radius: height / 2

    readonly property bool hovered: opacity.hovered
    opacity: opacity.value
    OpacityHover { id: opacity }

    Behavior on opacity {
        NumberAnimation { duration: Setting.animDuration }
    }

    TapHandler {
        enabled: root.clickable
        acceptedButtons: Qt.LeftButton
        onTapped: root.tapped()
    }

    TapHandler {
        enabled: root.clickable && root.rightClickable
        acceptedButtons: Qt.RightButton
        onTapped: root.rightTapped()
    }
}
