pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var allDevices: Networking.devices?.values ?? []
    readonly property var wifiDevice: allDevices.find(d => d.type === DeviceType.Wifi)
    readonly property var wiredDevice: allDevices.find(d => d.type === DeviceType.Wired)

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiConnected: wifiDevice?.connected ?? false
    readonly property bool ethernetConnected: wiredDevice?.connected ?? false
    readonly property var currentDevice: wiredDevice ?? (wifiEnabled && wifiDevice)

    readonly property string status: ethernetConnected ? "ethernet"
                                   : wifiConnected     ? "wifi"
                                   : "disconnected"

    readonly property var connectedWifiNetwork: wifiDevice?.networks?.values?.find(n => n.connected) ?? null;

    readonly property string currentSSID: connectedWifiNetwork?.name ?? ""
    readonly property int wifiSignalStrength: Math.round((connectedWifiNetwork?.signalStrength ?? 0) * 100)

    readonly property var wifiNetworks: {
        if (!wifiEnabled || !wifiDevice) return [];
        const result = [];
        const seen = new Set();
        for (const net of (wifiDevice.networks?.values ?? [])) {
            if (!net?.name || seen.has(net.name)) continue;
            seen.add(net.name);
            result.push({
                ssid: net.name,
                signal: Math.round(net.signalStrength * 100),
                secured: net.security !== WifiSecurityType.Open,
                connected: net.connected
            });
        }
        return result.sort((a, b) => b.signal - a.signal);
    }

    function toggleWifi() { Networking.wifiEnabled = !Networking.wifiEnabled; }
    function scanWifi() { if (wifiDevice && wifiEnabled) wifiDevice.scannerEnabled = true; }
    function disconnectWifi() { if (wifiDevice) wifiDevice.disconnect(); }
    
    function connectToWifi(ssid, password = "") {
        const net = wifiDevice?.networks?.values?.find(n => n.name === ssid);
        if (net) password ? net.connectWithPsk(password) : net.connect();
    }
}
