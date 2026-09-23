import QtQuick
import "../common"
import "../services" as Services

Rectangle {
    id: root

    implicitWidth: archLabel.implicitWidth + 25
    implicitHeight: ThemeManager.barHeight + 4
    radius: height / 2
    color: ThemeManager.backgroundStress
    border.color: ThemeManager.border
    border.width: ThemeManager.borderWidth
    opacity: opacity.value

    OpacityHover { id: opacity }

    ShellText {
        id: archLabel
        anchors.centerIn: parent
        text: "Arch"
        color: ThemeManager.textlight
    }

    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => Services.NiriService.action("ToggleOverview");
    }
}
