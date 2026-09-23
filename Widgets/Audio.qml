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

        Rectangle {
            id: audio
            readonly property bool isMuted: AudioService.isMuted

            implicitHeight: ThemeManager.barHeight
            implicitWidth: label.implicitWidth + 20
            radius: height / 2
            color: isMuted ? ThemeManager.audio : ThemeManager.background
            opacity: opacity.value
            OpacityHover { id: opacity }

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

            TapHandler {
                onTapped: AudioService.toggle()
            }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: blueberryProc.running = true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: wheel => AudioService.stepVolume(wheel.angleDelta.y > 0 ? 5 : -0.05)
            }
        }
    }

    Component {
        id: fallbackWidget

        Rectangle {
            implicitWidth: label.implicitWidth + 20
            implicitHeight: ThemeManager.barHeight
            radius: height / 2
            color: ThemeManager.backgroundStress
            opacity: 0.5

            ShellText {
                id: label
                anchors.centerIn: parent
                text: "   --%"
                color: ThemeManager.textlight
            }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: blueberryProc.running = !blueberryProc.running 
                // console.log(JSON.stringify(Pipewire.defaultAudioSink, null, 2))
            }
        }
    }

    Process {
        id: blueberryProc
        command: ["blueberry"]
        running: false
    }
}
