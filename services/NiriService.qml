pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

Singleton {
    id: root

    property var allWorkspaces: []
    property var workspaces: Utils.groupBy(allWorkspaces.sort((a, b) => a.idx - b.idx), it => it.output)
    property var workspacesById: Utils.indexBy(allWorkspaces, it => it.id)
    property var windows: []
    property var outputs: []
    property bool inOverview: false
    property var focusedWindow: windows.find(w => w.is_focused) || null

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET")

    Socket {
        path: root.socketPath
        connected: true

        onConnectedChanged: {
            if (connected) {
                write('"EventStream"\n')
                flush()
            }
        }

        parser: SplitParser {
            onRead: line => {
                if (!line) return
                try {
                    const event = JSON.parse(line)
                    const eventType = Object.keys(event)[0]
                    const handler = root.eventHandlers[eventType]
                    handler?.(event[eventType])
                } catch (e) {
                    console.warn("failed to parse Niri event:", e)
                }
            }
        }
    }

    Socket {
        id: requestSocket
        path: root.socketPath
        connected: true
        parser: SplitParser {
            onRead: line => {
                const res = JSON.parse(line)
                if (res.Err) console.warn("Niri Action Error:", res.Err)
            }
        }
    }

    property var eventHandlers: ({
        WorkspacesChanged(data) { root.allWorkspaces = data.workspaces },

        WorkspaceActivated(data) {
            const activatedOutput = workspacesById[data.id].output
            allWorkspaces = allWorkspaces.map(ws =>
                Object.assign({}, ws, {
                    is_active: ws.id === data.id || ws.is_active && ws.output !== activatedOutput,
                    is_focused: ws.id === data.id && data.focused
                })
            )
        },

        WorkspaceUrgencyChanged(data) {
            allWorkspaces = allWorkspaces.map(ws => {
                if (ws.id === data.id) {
                    return Object.assign({}, ws, { is_urgent: data.urgent })
                }
                return ws
            })
        },

        WindowsChanged(data) { windows = data.windows },

        WindowFocusChanged(data) {
            windows = windows.map(w => Object.assign({}, w, { is_focused: w.id === data.id }))
        },

        WindowClosed(data) { windows = windows.filter(w => w.id !== data.id) },

        WindowOpenedOrChanged(data) {
            const win = data.window
            const idx = windows.findIndex(w => w.id === win.id)
            let updated = windows.slice()
            if (idx >= 0) updated[idx] = win; else updated.push(win)
            windows = updated
        },

        OutputsChanged(data) { outputs = data.outputs },

        OverviewOpenedOrClosed(data) { inOverview = data.is_open },
    })

    function sendAction(actionData) {
        if (!requestSocket.connected) return
        requestSocket.write(JSON.stringify({ "Action": actionData }) + "\n")
        requestSocket.flush()
    }

    function action(actionName, msg = {}) {
        sendAction({[actionName]: msg })
    }

    function focusWorkspaceById(id) {
        sendAction({
            "FocusWorkspace": { "reference": { "Id": id } }
        })
    }
}
