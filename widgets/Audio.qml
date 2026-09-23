import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../common" as Common

Item {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool isMuted: (sink && sink.audio) ? sink.audio.muted : false
    readonly property int volume: (sink && sink.audio) ? Math.round(sink.audio.volume * 100) : 0

    function getAudioIcon() {
        if (root.isMuted) return "";

        const props = (root.sink && root.sink.properties) ? root.sink.properties : {};
        const formFactor = (props["device.form-factor"] || "").toLowerCase();
        if (formFactor === "headphone") return "";
        if (formFactor === "headset" || formFactor === "hands-free") return "󰋎";

        if (root.volume <= 33) return "";
        if (root.volume <= 66) return "";
        return "";
    }

    implicitWidth: audioBox.width
    implicitHeight: Common.ThemeManager.barHeight

    Rectangle {
        id: audioBox
        width: audioRow.implicitWidth + 20
        height: parent.height
        radius: height / 2
        color: root.isMuted ? Common.ThemeManager.backgroundStress : Common.ThemeManager.background
        opacity: Common.ThemeManager.opacity

        Row {
            id: audioRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.getAudioIcon()
                font.family: "FiraCode Nerd Font Propo, FontAwesome, sans-serif"
                font.pixelSize: Common.ThemeManager.fontSize
                color: root.isMuted ? Common.ThemeManager.textlight : Common.ThemeManager.audio
            }

            Text {
                text: root.volume + "%"
                font.family: Common.ThemeManager.fontFamily
                font.pixelSize: Common.ThemeManager.fontSize
                color: root.isMuted ? Common.ThemeManager.textlight : Common.ThemeManager.audio
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    if (root.sink && root.sink.audio) {
                        root.sink.audio.muted = !root.sink.audio.muted;
                    }
                } else if (mouse.button === Qt.RightButton) {
                    blueberryProc.running = true;
                }
            }

            onWheel: wheel => {
                if (!root.sink || !root.sink.audio) return;
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                const newVol = Math.max(0, Math.min(1.5, root.sink.audio.volume + delta));
                root.sink.audio.volume = newVol;
            }

            onEntered: audioBox.opacity = 1.0
            onExited: audioBox.opacity = Common.ThemeManager.opacity
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Process {
        id: blueberryProc
        command: ["blueberry"]
        running: false
    }
}
