# Display Modes

A Win+P-style display switcher for [Dux Shell (DMS)](https://duxlabs.dev) on
[niri](https://github.com/YaLTeR/niri).

Pick **laptop only**, **external only**, or **extended** from one menu. The
extended layout is remembered, so going back to it restores your monitors
exactly where they were.

![Display Modes picker](assets/screenshot.png)

## Features

- **One picker for the three common setups** — laptop only, one external
  monitor only, or every connected monitor.
- **Remembers the extended layout** — position, mode, scale, transform and
  refresh rate.
- **Optional Win+P shortcut** — enable a DMS-managed shortcut (for example
  `Mod+P`) in the plugin settings. It is off by default, an existing binding is
  never overwritten, and turning it off removes the binding.
- **Control Center tile and bar widget** — shows the current mode and switches
  with one click.
- **Live state without polling** — the widget follows DMS's output state and
  updates on output events.
- **Launcher integration** — type `mon` in the launcher.
- **IPC** — `dms ipc call displayModes internal|external|extend|cycle|menu`.
- **English and Russian UI**, plus a localized picker that follows the session
  locale.

![Display Modes in the Control Center](assets/control-center.png)

## Requirements

- Dux Shell 2.0.0 or newer
- niri
- `jq` and `bash`

The plugin is niri-only for now. Hyprland, Sway and other compositors are not
supported.

## Installation

From the plugin registry:

> Settings → Plugins → Browse → **Display Modes**, or
> `dms plugins install displayModes`

Manual installation:

```bash
git clone https://github.com/godsGived/dms-display-modes \
    ~/.config/dms/plugins/displayModes
dms restart
```

Then enable **Display Modes** in Settings → Plugins. Add the widget to a bar or
to the Control Center from the same settings page.

## Usage

| Action | How |
| --- | --- |
| Open the picker | Enable the shortcut in settings (for example `Mod+P`) |
| Control Center | Add the **Display Modes** tile |
| Bar | Add the widget and click it |
| Launcher | Type `mon` |
| IPC | `dms ipc call displayModes internal` |

Available IPC commands: `internal`, `external`, `extend`, `cycle`, `menu`.

The bundled script can also be used directly:

```bash
~/.config/dms/plugins/displayModes/scripts/display-modes current
~/.config/dms/plugins/displayModes/scripts/display-modes extend
```

## How it works

The plugin drives `niri msg output`:

- **Laptop only** and **External only** disable the other outputs and place the
  remaining one at `0,0`.
- **Extended** turns every connected output on and restores saved positions,
  scales and modes. If there is no saved layout, the built-in display is placed
  on the left and external monitors to the right.
- The extended layout is saved to
  `~/.local/state/dms-display-modes/layout.json` before switching to a
  single-monitor mode.

niri refuses overlapping output positions and silently auto-places instead, so
the script temporarily parks outputs to the right and verifies the final layout
before finishing.

## Settings

- **Register a picker shortcut** — off by default. Enable it and enter a
  combination such as `Mod+P`; turn it off to remove the binding. If the key is
  already used by another action, the plugin reports the conflict instead of
  replacing it.
- **Picker shortcut** — the combination used by the toggle above.
- **Show mode name in the bar** — hides the text label and keeps only the icon.

## Limitations

- niri only; the plugin uses niri's output commands.
- Mirroring is not included. Use `wl-mirror` for that.
- A single picker can be open at a time; repeated presses are ignored while the
  menu is visible.

## License

MIT © 2026 godsGived
