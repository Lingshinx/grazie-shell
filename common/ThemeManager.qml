pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Catppuccin Mocha 完整色板
    readonly property color rosewater: "#f4dbd6"
    readonly property color flamingo: "#f0c6c6"
    readonly property color pink: "#f5bde6"
    readonly property color mauve: "#c6a0f6"
    readonly property color red: "#ed8796"
    readonly property color maroon: "#ee99a0"
    readonly property color peach: "#f5a97f"
    readonly property color yellow: "#eed49f"
    readonly property color green: "#a6da95"
    readonly property color teal: "#8bd5ca"
    readonly property color sky: "#91d7e3"
    readonly property color sapphire: "#7dc4e4"
    readonly property color blue: "#8aadf4"
    readonly property color lavender: "#b7bdf8"
    readonly property color white: "#cad3f5"
    readonly property color subtext1: "#b8c0e0"
    readonly property color subtext0: "#a5adcb"
    readonly property color overlay2: "#939ab7"
    readonly property color overlay1: "#8087a2"
    readonly property color overlay0: "#6e738d"
    readonly property color surface2: "#5b6078"
    readonly property color surface1: "#494d64"
    readonly property color surface0: "#363a4f"
    readonly property color base: "#24273a"
    readonly property color mantle: "#1e2030"
    readonly property color crust: "#181926"

    // 语义化颜色 (Waybar 映射)
    readonly property color text: white
    readonly property color textlight: "#ffffff"
    readonly property color background: crust
    readonly property color backgroundStress: base
    readonly property color workspaces: base
    readonly property color workspacesButton: white
    readonly property color workspacesActive: base
    readonly property color workspacesUrgent: maroon
    readonly property color border: white
    readonly property color iconColor: white
    readonly property color audio: lavender
    readonly property color window: green
    readonly property color network: sky
    readonly property color clock: blue
    readonly property color error: red
    readonly property color warning: "#ff9a3c"

    // 样式常量 (Waybar 风格)
    readonly property int barHeight: 27
    readonly property int borderRadius: 15
    readonly property int borderRadiusSmall: 12
    readonly property int moduleMargin: 15
    readonly property int modulePaddingH: 10
    readonly property int modulePaddingV: 2
    readonly property int borderWidth: 3
    readonly property real opacity: 0.8
    readonly property int fontSize: 16
    readonly property string fontFamily: "Fira Sans Semibold"
    readonly property string monoFamily: "FiraCode Nerd Font Propo"
    readonly property int iconSize: 20
}
