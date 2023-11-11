# Hammerspoon Config
My personal [Hammerspoon](https://www.hammerspoon.org/) config.

The majority of hotkeys use the `MEH` modifier.
This is short for `Control+Option+Shift`.
I recommend remapping your caps lock key to this via [Karabiner-Elements](https://karabiner-elements.pqrs.org/) with a modification like [this one](https://ke-complex-modifications.pqrs.org/#meh_capslock).

# Modes
This config splits behavior between multiple modes.
You will start in Global mode and this is where the majority of hotkeys are.
Other modes can be accessed by pressing the associated hotkey.
Once in another mode, hitting `MEH+Escape` will return you to Global mode.

## Global Mode
| Hotkeys                     | Description                                               |
| --------------------------- | --------------------------------------------------------- |
| `MEH+a/b`                   | Snap window to left/right half of monitor                 |
| `MEH+f`                     | Fill monitor with window                                  |
| `MEH+s`                     | Make window small (1/2 monitor width, 1/2 monitor height) |
| `MEH+c`                     | Center window on monitor                                  |
| `MEH+m`                     | Move window to next monitor                               |
| `MEH+hjkl`                  | Resize window                                             |
| `MEH+Arrow Keys`            | Move window                                               |
| `Control+Option+Left/Right` | Cycle between applications on monitor                     |

## Screenshot Mode (WIP)
The goal of this mode is to be able to take screenshots using only keyboard shortcuts.
It still has a long way to go before being usable.
My idea is that it will display a rectangle that represents the screenshot area.
Then that rectangle can be moved, resized, snapped to a window, and snapped to visible edges, all using hotkeys.

## QuadClick Mode (WIP)
The goal of this mode was to be able to click anywhere on your screen with hotkeys.
I thought using a quad tree (like a binary tree, but in 2D) would make this quick and intuitive, but it turned out to be confusing and very slow.
I still like the idea of controlling the mouse via hotkeys, but I'll have to come up with a better method before it's useful.

