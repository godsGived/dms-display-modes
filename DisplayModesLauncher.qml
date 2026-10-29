import QtQuick
import Quickshell
import qs.Common
import qs.Services

Item {
    id: root

    property var pluginService: null
    property string pluginId: "displayModes"
    property string trigger: "mon"

    readonly property string scriptPath: Qt.resolvedUrl("scripts/display-modes").toString().replace("file://", "")

    signal itemsChanged()

    function getItems(query) {
        return [
            {
                name: I18n.trFor("displayModes", "Laptop only"),
                icon: "material:laptop",
                comment: I18n.trFor("displayModes", "Use the built-in display only"),
                action: "displayModes:internal",
                categories: [I18n.trFor("displayModes", "Display Modes")],
                keywords: ["display", "monitor", "screen", "laptop", "internal"]
            },
            {
                name: I18n.trFor("displayModes", "External only"),
                icon: "material:desktop_windows",
                comment: I18n.trFor("displayModes", "Use an external monitor only"),
                action: "displayModes:external",
                categories: [I18n.trFor("displayModes", "Display Modes")],
                keywords: ["display", "monitor", "screen", "external", "hdmi", "displayport"]
            },
            {
                name: I18n.trFor("displayModes", "Extended"),
                icon: "material:splitscreen",
                comment: I18n.trFor("displayModes", "Extend the desktop across every connected monitor"),
                action: "displayModes:extend",
                categories: [I18n.trFor("displayModes", "Display Modes")],
                keywords: ["display", "monitor", "screen", "extend", "extended", "both"]
            }
        ];
    }

    function executeItem(item) {
        if (!item?.action)
            return;

        const mode = item.action.split(":")[1];
        if (mode !== "internal" && mode !== "external" && mode !== "extend")
            return;

        Quickshell.execDetached([scriptPath, mode]);
        ToastService.showInfo(I18n.trFor("displayModes", "Display mode"), item.name);
    }
}
