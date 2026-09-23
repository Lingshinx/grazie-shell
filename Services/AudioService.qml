pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property bool isReady: sink ? sink.ready : false
    readonly property bool isMuted: (isReady && audio) ? audio.muted : false
    readonly property int volume: (isReady && audio) ? Math.round(audio.volume * 100) : 0

    function toggle() {
        if (audio) audio.muted = !isMuted
    }

    function setVolume(volume) {
        if (audio) audio.volume = Math.max(0, Math.min(100, volume - volume % 5)) / 100
    }

    function stepVolume(percent) {
        if (audio) setVolume(volume + percent)
    }

    PwObjectTracker {
        // objects: Pipewire.nodes.values.filter(node => node.audio && !node.isStream)
        objects: [Pipewire.defaultAudioSink]
    }

}
