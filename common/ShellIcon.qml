import QtQuick

Text {
    font.family: ThemeManager.monoFamily
    font.pixelSize: ThemeManager.iconSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: Qt.alpha(ThemeManager.iconColor, ThemeManager.opacity)
}
