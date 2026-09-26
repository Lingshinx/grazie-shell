pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property int animDuration: 200

    component MarginSetting: QtObject{
        property int top: 10
        property int left: 14
        property int right: 14
    }

    component BarSetting: QtObject {
        property MarginSetting margins: MarginSetting {}
    }
    property BarSetting bar: BarSetting {}
}
