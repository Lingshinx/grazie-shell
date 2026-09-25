import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common

Rectangle {
    id: root

    property var parentWindow: null
    property bool isAtBottom: false

    // 自动根据内部的 Row 撑开自身尺寸
    implicitWidth: mainRow.implicitWidth
    implicitHeight: ThemeManager.barHeight
    color: "transparent"

    visible: items.length > 0
    opacity: opacityHover.value
    OpacityHover { id: opacityHover }
    Behavior on opacity { NumberAnimation { duration: 200 } }

    // --- 托盘数据与状态管理 ---
    property bool menuOpen: false
    property var currentTrayMenu: null

    readonly property real trayItemSize: ThemeManager.barHeight - 6

    readonly property var items: SystemTray.items.values
    readonly property int automaticVisibleItemLimit: Math.min(items.length, 8)

    readonly property var mainBarItems: items.slice(0, automaticVisibleItemLimit)
    readonly property var hiddenBarItems: items.slice(automaticVisibleItemLimit)
    readonly property bool hasHiddenItems: hiddenBarItems.length > 0
    readonly property bool inlineExpanded: hasHiddenItems && menuOpen

    function trayIconSourceFor(trayItem) {
        let icon = trayItem?.icon;
        if (!icon) return ""
        if (icon.includes("?path=")) {
            const split = icon.split("?path=");
            if (split.length !== 2) return icon;
            let fileName = split[0].substring(split[0].lastIndexOf("/") + 1);
            return `file://${split[1]}/${fileName}`;
        }
        if (icon.startsWith("/")) return `file://${icon}`;
        return icon;
    }


    function callContextMenuFallback(trayItemId, globalX, globalY) {
        const script = ['ITEMS=$(dbus-send --session --print-reply --dest=org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierWatcher string:RegisteredStatusNotifierItems 2>/dev/null)', 'while IFS= read -r line; do', '  line="${line#*\\\"}"', '  line="${line%\\\"*}"', '  [ -z "$line" ] && continue', '  BUS="${line%%/*}"', '  OBJ="/${line#*/}"', '  ID=$(dbus-send --session --print-reply --dest="$BUS" "$OBJ" org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierItem string:Id 2>/dev/null | grep -oP "(?<=\\\")(.*?)(?=\\\")" | tail -1)', '  if [ "$ID" = "$1" ]; then', '    dbus-send --session --type=method_call --dest="$BUS" "$OBJ" org.kde.StatusNotifierItem.ContextMenu int32:"$2" int32:"$3"', '    exit 0', '  fi', 'done <<< "$ITEMS"'].join("\n");
        Quickshell.execDetached(["bash", "-c", script, "_", trayItemId, String(globalX), String(globalY)]);
    }

    function showForTrayItem(item, anchor) {
        if (!parentScreen) return;
        if (currentTrayMenu) {
            currentTrayMenu.showMenu = false;
            currentTrayMenu.destroy();
        }
        PopoutManager.closeAllPopouts();
        ModalManager.closeAllModalsExcept(null);
        currentTrayMenu = trayMenuComponent.createObject(null);
        if (currentTrayMenu) {
            currentTrayMenu.showForTrayItem(item, anchor, parentScreen, isAtBottom);
        }
    }

    Row {
        id: mainRow
        spacing: 0
        anchors.fill: parent

        // 1. 始终显示的图标
        Repeater {
            model: root.mainBarItems
            delegate: trayItemDelegate
        }

        // 2. 展开/折叠按钮
        Item {
            width: root.trayItemSize
            height: ThemeManager.barHeight
            visible: root.hasHiddenItems

            Rectangle {
                width: root.trayItemSize
                height: root.trayItemSize
                anchors.centerIn: parent
                radius: Theme.cornerRadius
                color: caretArea.pressed ? Theme.surfaceContainerHigh : (caretArea.containsMouse ? Theme.surfaceContainer : "transparent")
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: root.menuOpen ? "<" : ">"
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.widgetTextColor
                }

                MouseArea {
                    id: caretArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.menuOpen = !root.menuOpen
                }
            }
        }

        // 3. 内联折叠的图标
        Repeater {
            model: root.hiddenBarItems
            delegate: inlineExpandedTrayItemDelegate
        }
    }

    // --- 通用图标代理组件 ---
    Component {
        id: trayItemDelegate
        Item {
            property var trayItem: modelData
            width: root.trayItemSize
            height: ThemeManager.barHeight

            Rectangle {
                id: visualContent
                width: root.trayItemSize
                height: root.trayItemSize
                anchors.centerIn: parent
                radius: Theme.cornerRadius
                color: trayItemArea.pressed ? Theme.surfaceContainerHigh : (trayItemArea.containsMouse ? Theme.surfaceContainer : "transparent")
                Behavior on color { ColorAnimation { duration: 100 } }

                IconImage {
                    id: iconImg
                    anchors.centerIn: parent
                    width: root.trayItemSize * 0.8
                    height: width
                    source: root.trayIconSourceFor(trayItem)
                    visible: status === Image.Ready
                }
                
                Text {
                    anchors.centerIn: parent
                    visible: !iconImg.visible
                    text: trayItem?.id ? trayItem.id.charAt(0).toUpperCase() : "?"
                    font.pixelSize: 10
                    color: Theme.widgetTextColor
                }
            }

            MouseArea {
                id: trayItemArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        if (!trayItem.onlyMenu) trayItem.activate();
                        else if (trayItem.hasMenu) root.showForTrayItem(trayItem, visualContent);
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.hasMenu) root.showForTrayItem(trayItem, visualContent);
                        else {
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            root.callContextMenuFallback(trayItem.id, Math.round(gp.x), Math.round(gp.y));
                        }
                    }
                }
            }
        }
    }

    // --- 内联折叠图标代理 ---
    Component {
        id: inlineExpandedTrayItemDelegate
        Item {
            property var trayItem: modelData
            width: root.inlineExpanded ? root.trayItemSize : 0
            height: ThemeManager.barHeight
            visible: width > 0
            clip: true

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            Rectangle {
                id: inlineVisualContent
                width: root.trayItemSize
                height: root.trayItemSize
                anchors.verticalCenter: parent.verticalCenter
                radius: Theme.cornerRadius
                
                color: inlineTrayItemArea.pressed ? Theme.surfaceContainerHigh : (inlineTrayItemArea.containsMouse ? Theme.surfaceContainer : "transparent")
                Behavior on color { ColorAnimation { duration: 100 } }

                opacity: root.inlineExpanded ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                IconImage {
                    id: inlineIconImg
                    anchors.centerIn: parent
                    width: root.trayItemSize * 0.8
                    height: width
                    source: root.trayIconSourceFor(trayItem)
                    visible: status === Image.Ready
                }
                
                Text {
                    anchors.centerIn: parent
                    visible: !inlineIconImg.visible
                    text: trayItem?.id ? trayItem.id.charAt(0).toUpperCase() : "?"
                    font.pixelSize: 10
                    color: Theme.widgetTextColor
                }
            }

            MouseArea {
                id: inlineTrayItemArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                enabled: root.inlineExpanded

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        if (!trayItem.onlyMenu) trayItem.activate();
                        else if (trayItem.hasMenu) root.showForTrayItem(trayItem, inlineVisualContent);
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.hasMenu) root.showForTrayItem(trayItem, inlineVisualContent);
                        else {
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            root.callContextMenuFallback(trayItem.id, Math.round(gp.x), Math.round(gp.y));
                        }
                    }
                }
            }
        }
    }

    Component {
        id: trayMenuComponent
        Rectangle {
            id: menuRoot
            property var trayItem: null
            property var anchorItem: null
            property var parentScreen: null
            property bool isAtBottom: false
            property bool showMenu: false
            property var menuHandle: null

            function showForTrayItem(item, anchor, screen, atBottom) {
                trayItem = item;
                anchorItem = anchor;
                parentScreen = screen;
                isAtBottom = atBottom;
                menuHandle = item?.menu;
                showMenu = true;
            }

            width: 0; height: 0; color: "transparent"

            PanelWindow {
                id: menuWindow
                visible: menuRoot.showMenu && (menuRoot.trayItem?.hasMenu ?? false)
                screen: menuRoot.parentScreen
                WlrLayershell.keyboardFocus: KeyboardFocus.keyboardFocus(menuRoot.showMenu, null)
                color: "transparent"
                anchors.fill: parent

                property point anchorPos: Qt.point(screen.width / 2, screen.height / 2)

                onVisibleChanged: {
                    if (visible) {
                        const localPos = (menuRoot.anchorItem || root).mapToItem(null, 0, 0);
                        const targetY = menuRoot.isAtBottom ? screen.height - (ThemeManager.barHeight + 4 + 10) : ThemeManager.barHeight + 4 + 10;
                        anchorPos = Qt.point(localPos.x + (menuRoot.anchorItem || root).width / 2, targetY);
                    }
                }

                Item {
                    id: trayMenuContainer
                    width: menuColumn.implicitWidth + 16
                    height: menuColumn.implicitHeight + 16
                    
                    x: Math.max(10, Math.min(menuWindow.width - width - 10, menuWindow.anchorPos.x - width / 2))
                    y: menuRoot.isAtBottom ? menuWindow.anchorPos.y - height : menuWindow.anchorPos.y
                    
                    opacity: menuRoot.showMenu ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.surfaceContainer
                        radius: Theme.cornerRadius
                        border.color: Theme.outline; border.width: 1
                    }

                    QsMenuOpener { id: rootOpener; menu: menuRoot.menuHandle }

                    Column {
                        id: menuColumn
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Repeater {
                            model: rootOpener.children
                            Rectangle {
                                property var menuEntry: modelData
                                width: Math.max(150, trayMenuContainer.width - 16)
                                height: menuEntry?.isSeparator ? 1 : 28
                                color: itemArea.pressed ? Theme.surfaceContainerHigh : (itemArea.containsMouse ? Theme.surfaceContainerHighest : "transparent")
                                Behavior on color { ColorAnimation { duration: 100 } }
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    text: menuEntry?.text || ""
                                    font.pixelSize: 12
                                    color: Theme.surfaceText
                                }

                                MouseArea {
                                    id: itemArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !menuEntry?.isSeparator
                                    onClicked: {
                                        if (menuEntry?.activate) menuEntry.activate();
                                        else if (menuEntry?.triggered) menuEntry.triggered();
                                        menuRoot.showMenu = false;
                                    }
                                }
                            }
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: menuRoot.showMenu = false
                }
            }
        }
    }
}
