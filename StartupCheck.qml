import QtQuick
import qs.Common
import qs.Services

QtObject {
    function check(done) {
        if (!CompositorService.isNiri) {
            done({
                title: I18n.trFor("displayModes", "Niri is required"),
                details: I18n.trFor("displayModes", "Display Modes uses niri's output commands. Hyprland and other compositors are not supported yet.")
            });
            return;
        }

        Proc.runCommand("displayModes.dependencyCheck", ["sh", "-c", "command -v niri && command -v jq && command -v bash"], (stdout, exitCode) => {
            if (exitCode === 0) {
                done(null);
                return;
            }
            done({
                title: I18n.trFor("displayModes", "Missing dependencies"),
                details: I18n.trFor("displayModes", "Install niri, jq and bash, then enable the plugin again.")
            });
        });
    }
}
