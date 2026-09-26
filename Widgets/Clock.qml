import QtQuick
import Quickshell
import qs.Common
import qs

BarWidget {
    id: root

    implicitWidth: metrics.width + 25
    implicitHeight: ThemeManager.barHeight + 4
    color: ThemeManager.backgroundStress
    border.color: ThemeManager.border
    border.width: ThemeManager.borderWidth
    property string format: (detailed ? "HH:mm:ss" : "HH:mm") + (hovered ? " ddd dd" : "")

    ShellText {
        id: label
        anchors.centerIn: parent
        property string format: root.format
        text: Qt.formatDateTime(clock.date, format)
        color: ThemeManager.textlight
        font.features: {"tnum": 1}

        Behavior on format {
            SequentialAnimation {
                id: formatTransition
                NumberAnimation { target: label; property: "opacity"; to: 0; duration: Setting.animDuration }
                PropertyAction {}
                NumberAnimation { target: label; property: "opacity"; to: 1; duration: Setting.animDuration }
            }
        }
    }

    SystemClock {
        id: clock
        precision: root.detailed ? SystemClock.Seconds : SystemClock.Seconds
    }

    property bool detailed: false
    onTapped: detailed = !detailed
    rightClickable: false

    Behavior on implicitWidth {
        NumberAnimation { duration: Setting.animDuration }
    }

    TextMetrics {
        id: metrics
        font: label.font
        text: Qt.formatDateTime(clock.date, root.format)
    }

}
