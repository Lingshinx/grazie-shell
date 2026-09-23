import QtQuick

HoverHandler {
    cursorShape: Qt.PointingHandCursor
    property real unhoveredValue: ThemeManager.opacity
    property real hoveredValue: 1.0
    property real value: hovered ? hoveredValue : unhoveredValue
}
