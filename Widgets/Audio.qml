pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services

Item {
    id: root

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight:loader.item ? loader.item.implicitHeight: 0

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: AudioService.isReady ? realAudioWidget : fallbackWidget
    }

    Component {
        id: realAudioWidget

        BarWidget {
            id: audio
            readonly property bool isMuted: AudioService.isMuted

            implicitWidth: label.implicitWidth + 20
            color: isMuted ? ThemeManager.audio : ThemeManager.background

            readonly property string icon: {
                if (isMuted) return "";
                const props = AudioService.sink.properties ?? {}
                const formFactor = (props["device.form-factor"] ?? "").toLowerCase();
                if (formFactor === "headphone") return "";
                if (formFactor === "headset" || formFactor === "hands-free") return "󰋎";
                const volume = AudioService.volume
                if (volume <= 33) return "";
                if (volume <= 66) return "";
                return "";
            }

            ShellText {
                id: label
                anchors.centerIn: parent
                text: `${audio.icon}    ${AudioService.volume}%`
                color: audio.isMuted ? ThemeManager.background : ThemeManager.audio
            }

            onTapped: AudioService.toggle()
            onRightTapped: blueberryProc.running = true

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: wheel => AudioService.stepVolume(wheel.angleDelta.y > 0 ? 5 : -0.05)
            }
        }
    }

    Component {
        id: fallbackWidget

        BarWidget {
            implicitWidth: label.implicitWidth + 20
            color: ThemeManager.backgroundStress
            opacity: 0.5
            clickable: false

            ShellText {
                id: label
                anchors.centerIn: parent
                text: "   --%"
                color: ThemeManager.textlight
            }
        }
    }

    Process {
        id: blueberryProc
        command: ["blueberry"]
        running: false
    }
}
