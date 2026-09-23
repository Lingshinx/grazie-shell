import QtQuick
import Quickshell
import Quickshell.Io
import "../common"


Image {
    id: wallpaperIcon
    width: 20
    height: 20
    anchors.verticalCenter: parent.verticalCenter
    source: "../assets/openai.svg"
    fillMode: Image.PreserveAspectFit
    opacity: opacity.value
    sourceSize.width: 24
    sourceSize.height: 24
 
    OpacityHover {id: opacity}

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: wallpaperProc.running = true

    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Process {
        id: wallpaperProc
        command: ["bash", "-c", "~/.config/lingshin/scripts/swww/random.sh"]
        running: false
    }
}
