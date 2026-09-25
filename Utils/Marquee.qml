import QtQuick

SequentialAnimation {
    id: root
    property int distance
    property int from : 0
    property int pauseDuration: 500
    property int moveSpeed: 20
    loops: Animation.Infinite
    PauseAnimation { duration: root.pauseDuration }
    NumberAnimation {
        to: root.from - root.distance
        duration: Math.max(0, root.distance * root.moveSpeed)
        easing.type: Easing.InOutSine
    }
    PauseAnimation { duration: root.pauseDuration }
    NumberAnimation {
        to: root.from
        duration: Math.max(0, root.distance * root.moveSpeed)
        easing.type: Easing.InOutSine
    }
}

