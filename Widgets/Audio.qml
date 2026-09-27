pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Services

BarWidget {
  id: audio
  readonly property bool isMuted: AudioService.isMuted

  implicitWidth: label.implicitWidth + 20
  color: isMuted ? ThemeManager.audio : ThemeManager.background
  onTapped: AudioService.toggle()

  readonly property string icon: {
      if (isMuted) return "";
      const volume = AudioService.volume
      if (volume <= 33) return "";
      if (volume <= 66) return "";
      return "";
  }

  ShellText {
      id: label
      anchors.centerIn: parent
      text: `${audio.icon}   ${AudioService.volume}%`
      color: audio.isMuted ? ThemeManager.background : ThemeManager.audio
  }

  MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      onWheel: wheel => AudioService.stepVolume(wheel.angleDelta.y > 0 ? 5 : -0.05)
  }
}
