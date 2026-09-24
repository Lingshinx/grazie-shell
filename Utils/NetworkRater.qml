import QtQuick
import Quickshell.Io

Timer {
    id: root
    required property string interfaceName
    property bool enabled: true

    function parse(file) {
        return parseInt(file.text().trim())
    }

    property real tx
    property real rx
    property real receive: 0
    property real transmit: 0

    interval: 1000
    repeat: true
    running: enabled
    onTriggered: {
        tx = parse(txFile)
        rx = parse(rxFile)
        txFile.reload()
        rxFile.reload()
    }

    property FileView txFile: FileView {
        path: root.interfaceName ? "/sys/class/net/" + root.interfaceName + "/statistics/tx_bytes" : ""
        onLoaded: root.transmit = root.parse(this) - root.tx
    }

    property FileView rxFile: FileView {
        path: root.interfaceName ? "/sys/class/net/" + root.interfaceName + "/statistics/rx_bytes" : ""
        onLoaded: root.receive = root.parse(this) - root.rx
    }
}
