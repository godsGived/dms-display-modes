import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Modules.Plugins
import qs.Modules.ControlCenter.Widgets

PluginComponent {
    id: root

    readonly property string scriptPath: Qt.resolvedUrl("scripts/display-modes").toString().replace("file://", "")
    readonly property bool showBarLabel: pluginData.showBarLabel ?? true

    property string currentMode: "off"

    function updateMode() {
        const outs = WlrOutputService.outputs || [];
        const active = [];
        for (const output of outs) {
            if (output.enabled)
                active.push(output.name);
        }
        if (active.length >= 2)
            currentMode = "extend";
        else if (active.length === 1)
            currentMode = /^(eDP|LVDS|DSI)/i.test(active[0]) ? "internal" : "external";
        else
            currentMode = "off";
    }

    Component.onCompleted: updateMode()

    Connections {
        target: WlrOutputService

        function onStateChanged() {
            root.updateMode();
        }
    }

    property bool busy: false
    property string pendingMode: ""

    function modeLabel(mode) {
        switch (mode) {
        case "internal":
            return I18n.trFor("displayModes", "Laptop only");
        case "external":
            return I18n.trFor("displayModes", "External only");
        case "extend":
            return I18n.trFor("displayModes", "Extended");
        default:
            return I18n.trFor("displayModes", "Unknown");
        }
    }

    function modeShortLabel(mode) {
        switch (mode) {
        case "internal":
            return I18n.trFor("displayModes", "Laptop");
        case "external":
            return I18n.trFor("displayModes", "External");
        case "extend":
            return I18n.trFor("displayModes", "Extended");
        default:
            return I18n.trFor("displayModes", "Display");
        }
    }

    function modeIcon(mode) {
        switch (mode) {
        case "internal":
            return "laptop";
        case "external":
            return "desktop_windows";
        case "extend":
            return "splitscreen";
        default:
            return "monitor";
        }
    }

    function applyMode(mode) {
        if (busy)
            return;
        busy = true;
        pendingMode = mode;
        actionProcess.command = [scriptPath, mode];
        actionProcess.running = true;
    }

    readonly property var modeActions: [
        {
            text: I18n.trFor("displayModes", "Laptop only"),
            icon: "laptop",
            active: currentMode === "internal",
            enabled: !busy,
            trigger: () => applyMode("internal")
        },
        {
            text: I18n.trFor("displayModes", "External only"),
            icon: "desktop_windows",
            active: currentMode === "external",
            enabled: !busy,
            trigger: () => applyMode("external")
        },
        {
            text: I18n.trFor("displayModes", "Extended"),
            icon: "splitscreen",
            active: currentMode === "extend",
            enabled: !busy,
            trigger: () => applyMode("extend")
        }
    ]

    ccWidgetIcon: modeIcon(currentMode)
    ccWidgetPrimaryText: I18n.trFor("displayModes", "Display mode")
    ccWidgetSecondaryText: modeLabel(currentMode)
    ccWidgetIsActive: currentMode !== "off"
    ccWidgetIsToggle: false
    ccExpandedMinimumHeight: Theme.listItemHeight
    ccDetailHeight: Theme.listItemHeight * 3 + Theme.groupedListGap * 2

    ccExpandedContent: Component {
        CcTileActions {
            actions: root.modeActions
        }
    }

    ccDetailContent: Component {
        CcTileActions {
            actions: root.modeActions
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DIcon {
                name: root.modeIcon(root.currentMode)
                size: root.iconSize
                color: root.currentMode === "off" ? Theme.surfaceVariantText : Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: root.showBarLabel
                text: root.modeShortLabel(root.currentMode)
                font.pixelSize: root.textSize
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DIcon {
                name: root.modeIcon(root.currentMode)
                size: root.iconSize
                color: root.currentMode === "off" ? Theme.surfaceVariantText : Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: root.showBarLabel
                text: root.modeShortLabel(root.currentMode)
                font.pixelSize: root.textSize
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutWidth: 300
    popoutHeight: 270

    popoutContent: Component {
        PopoutComponent {
            id: popup

            headerText: I18n.trFor("displayModes", "Display mode")
            detailsText: I18n.trFor("displayModes", "Choose which displays to use.")

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                Repeater {
                    model: root.modeActions

                    delegate: DButton {
                        required property var modelData

                        width: parent.width
                        maximumWidth: parent.width
                        text: (modelData.active ? "✓  " : "") + modelData.text
                        iconName: modelData.icon
                        enabled: modelData.enabled
                        onClicked: {
                            modelData.trigger();
                            popup.closePopout();
                        }
                    }
                }
            }
        }
    }

    Process {
        id: actionProcess

        environment: ({
                "DISPLAY_MODES_NOTIFY": "0"
            })

        stderr: StdioCollector {
            id: actionStderr
        }

        onExited: exitCode => {
            root.busy = false;
            if (exitCode === 0) {
                ToastService.showInfo(I18n.trFor("displayModes", "Display mode"), root.modeLabel(root.pendingMode));
            } else {
                const details = actionStderr.text.trim();
                ToastService.showError(I18n.trFor("displayModes", "Could not switch display mode"), details || I18n.trFor("displayModes", "The display backend returned an error."));
            }
            root.pendingMode = "";
        }
    }
}
