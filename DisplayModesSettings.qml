import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "displayModes"

    StyledText {
        width: parent.width
        text: I18n.trFor("displayModes", "Display Modes")
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: I18n.trFor("displayModes", "Switch between the built-in display, an external monitor, and the extended desktop. The extended layout is remembered and restored.")
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StringSetting {
        settingKey: "shortcut"
        label: I18n.trFor("displayModes", "Picker shortcut")
        description: I18n.trFor("displayModes", "DMS-managed shortcut for the display picker, for example Mod+P. Leave empty to remove it. An existing shortcut is never replaced.")
        placeholder: "Mod+P"
        defaultValue: "Mod+P"
    }

    ToggleSetting {
        settingKey: "showBarLabel"
        label: I18n.trFor("displayModes", "Show mode name in the bar")
        description: I18n.trFor("displayModes", "Show a short label next to the monitor icon. Disable it to keep the bar compact.")
        defaultValue: true
    }

    StyledText {
        width: parent.width
        text: I18n.trFor("displayModes", "Add the widget to the bar or Control Center from the DMS settings. The picker is also available as the \"mon\" launcher trigger and through dms ipc call displayModes.")
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }
}
