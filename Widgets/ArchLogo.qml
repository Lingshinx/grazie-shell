import QtQuick
import qs.Common
import qs.Services

BarWidget {
    id: root

    implicitWidth: archLabel.implicitWidth + 25
    implicitHeight: ThemeManager.barHeight + 4
    color: ThemeManager.backgroundStress
    border.color: ThemeManager.border
    border.width: ThemeManager.borderWidth

    ShellText {
        id: archLabel
        anchors.centerIn: parent
        text: "Arch"
        color: ThemeManager.textlight
    }

    onTapped: NiriService.action("ToggleOverview")
    rightClickable: false
}
