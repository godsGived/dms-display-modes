import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string scriptPath: Qt.resolvedUrl("scripts/display-modes").toString().replace("file://", "")
    readonly property string keybindScriptPath: Qt.resolvedUrl("scripts/displaymodes-keybind").toString().replace("file://", "")

    property string appliedShortcut: "__unset__"
    property string pendingShortcut: ""
    property string runningShortcut: ""
    property bool firstSync: true

    function syncKeybind() {
        const enabled = pluginData.manageShortcut === true;
        const shortcut = enabled ? String(pluginData.shortcut ?? "").trim() : "";
        if (shortcut === appliedShortcut && !keybindProcess.running)
            return;

        pendingShortcut = shortcut;
        if (keybindProcess.running)
            return;

        runningShortcut = shortcut;
        keybindProcess.command = [keybindScriptPath, shortcut, "niri"];
        keybindProcess.running = true;
    }

    function runScript(mode) {
        Quickshell.execDetached([scriptPath, mode]);
    }

    Component.onCompleted: Qt.callLater(syncKeybind)

    onPluginDataChanged: Qt.callLater(syncKeybind)

    Connections {
        target: pluginService

        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === root.pluginId)
                Qt.callLater(root.syncKeybind);
        }
    }

    Process {
        id: keybindProcess

        stderr: StdioCollector {
            id: keybindStderr
        }

        onExited: exitCode => {
            const shortcut = root.runningShortcut;
            if (exitCode === 0) {
                root.appliedShortcut = shortcut;
                if (!root.firstSync && shortcut.length > 0)
                    ToastService.showInfo(I18n.trFor("displayModes", "Shortcut updated"), shortcut);
            } else {
                const details = keybindStderr.text.trim();
                ToastService.showError(I18n.trFor("displayModes", "Could not register the shortcut"), details || I18n.trFor("displayModes", "Choose another shortcut in the plugin settings."));
            }
            root.firstSync = false;
            if (root.pendingShortcut !== root.runningShortcut)
                Qt.callLater(root.syncKeybind);
        }
    }

    IpcHandler {
        target: "displayModes"

        function menu(): string {
            root.runScript("menu");
            return "OK";
        }

        function internal(): string {
            root.runScript("internal");
            return "OK";
        }

        function external(): string {
            root.runScript("external");
            return "OK";
        }

        function extend(): string {
            root.runScript("extend");
            return "OK";
        }

        function cycle(): string {
            root.runScript("cycle");
            return "OK";
        }
    }
}
