# design-95

A Windows 95-style UI design system for Godot 4. All components are theme-driven — no per-node scripts required for appearance. Pixel-accurate 9-slice textures, nearest-neighbour filtering.

This repository is the **source of truth**. When building a project that uses this system, read this file first and follow it exactly.

---

## Architecture

The theme is split across two files with distinct roles. Understanding this prevents the most common mistakes.

### `webcore_theme.tres` — style data

The master `Theme` resource. It holds every color, stylebox, font assignment, and icon. The Godot editor reads this file statically, so all components are visible with correct styles in the editor viewport without running the project.

This file references component `.tres` files in each subdirectory (e.g. `theme/button/button_normal_texture.tres`). Those files are self-contained: a project that needs only the button component can copy `theme/button/` and load the `.tres` directly.

### `ThemeSetup.gd` — type variation registration

Godot 4 does not allow `Theme.set_type_variation()` to be expressed inside a `.tres` file. Custom variation names (e.g. `Win95Dropdown`, `TitleBarButton`) must be registered at runtime before any scene node resolves its theme cache.

`ThemeSetup.gd` is registered as an autoload so it runs first. **Without it, every node that uses a custom `theme_type_variation` will render with default Godot styles at runtime**, even though the editor preview looks correct.

> **Editor preview note:** In the editor, type variations are not registered (the autoload does not run). Nodes with a custom `theme_type_variation` fall back to their base type style in the editor viewport. This is expected — the styles are correct when the project runs.

---

## Setup

### 1. Copy files into your project

```
fonts/
theme/
```

`fonts/` contains `W95FA.otf` (the Win95-accurate bitmap font).  
`theme/` contains all style resources, textures, and the autoload script.

### 2. Configure `project.godot`

```ini
[autoload]
ThemeSetup="*res://theme/ThemeSetup.gd"

[gui]
theme/custom="res://theme/webcore_theme.tres"

[rendering]
textures/canvas_textures/default_texture_filter=0
```

`default_texture_filter=0` sets nearest-neighbour filtering globally. Without it, pixel textures render blurred.

---

## Components

Every component is a standard Godot node with `theme_type_variation` set. No custom scripts are required.

---

### Label

Plain text. Black, 12 px, 1 px padding on all sides so text never touches the container edge. Applied globally to all `Label` nodes — no variation needed.

```gdscript
var lbl = Label.new()
lbl.text = "Hello"
```

---

### SectionLabel

Bold section heading. Uses a `FontVariation` of W95FA with `variation_embolden = 1.0` at 13 px.

```gdscript
var lbl = Label.new()
lbl.theme_type_variation = &"SectionLabel"
lbl.text = "Controls"
```

---

### Button

Standard raised Win95 button. Applied globally — no variation needed.

```gdscript
var btn = Button.new()
btn.text = "OK"
```

---

### TitleBarButton

Compact button for use inside title bars. Same textures as `Button` with reduced padding to fit within the 20 px title bar height.

```gdscript
var btn = Button.new()
btn.theme_type_variation = &"TitleBarButton"
btn.custom_minimum_size = Vector2(16, 0)
btn.text = "_"
```

---

### Panel

Generic gray background panel with a Win95 raised bevel border. Applied globally — no variation needed.

```gdscript
var panel = Panel.new()
```

---

### WindowPanel

Raised bevel panel intended as the outer container of a window.

```gdscript
var win = Panel.new()
win.theme_type_variation = &"WindowPanel"
```

Typical window structure:

```
Panel (WindowPanel)
└── VBoxContainer              2 px inset on all sides
    ├── Panel (TitleBarActive)
    ├── Panel                  content area
    └── Panel                  status bar
```

---

### TitleBarActive / TitleBarInactive

Solid-fill panels for window title bars. `TitleBarActive` is navy blue (`#000080`). `TitleBarInactive` is gray (`#808080`). Recommended height: 20 px.

```gdscript
var bar = Panel.new()
bar.theme_type_variation = &"TitleBarActive"   # or &"TitleBarInactive"
bar.custom_minimum_size = Vector2(0, 20)
```

Title text is white — use a `Label` with `theme_type_variation = &"TitleBarLabel"` inside. Window control buttons use `TitleBarButton`.

Full title bar structure:

```
Panel (TitleBarActive)                   custom_minimum_size = (0, 20)
└── HBoxContainer                        anchors fill parent, left offset = 4
    ├── Label (TitleBarLabel)            size_flags_horizontal = EXPAND
    │     text = "window title"
    └── HBoxContainer
        ├── Button (TitleBarButton)      text = "_",  min_width = 16
        ├── Button (TitleBarButton)      text = "□",  min_width = 16
        └── Button (TitleBarButton)      text = "X",  min_width = 16
```

---

### Win95MenuBar

Gray top bar with a 1 px dark separator on the bottom edge. Recommended height: 22 px.

```gdscript
var bar = Panel.new()
bar.theme_type_variation = &"Win95MenuBar"
bar.custom_minimum_size = Vector2(0, 22)
```

> `"MenuBar"` cannot be used as a variation name — it conflicts with a Godot built-in class. Always use `"Win95MenuBar"`.

---

### LineEdit

Win95 sunken text input. Inset border (dark top/left, light bottom/right), white fill. Placeholder text renders in dark gray. Applied globally — no variation needed.

```gdscript
var field = LineEdit.new()
field.placeholder_text = "Type something..."
```

When placed inside a container, set `custom_minimum_size = Vector2(1, 0)` to prevent layout warnings.

---

### Win95Dropdown

Win95 combo box. Sunken field showing the selected item with a down-arrow button on the right. Built on `OptionButton`.

```gdscript
var drop = OptionButton.new()
drop.theme_type_variation = &"Win95Dropdown"
drop.add_item("Option 1")
drop.add_item("Option 2")
drop.add_item("Option 3")
drop.select(0)   # always set a default selection
```

In `.tscn` files:

```
[node name="Dropdown" type="OptionButton" ...]
theme_type_variation = &"Win95Dropdown"
selected = 0
item_count = 3
popup/item_0/text = "Option 1"
popup/item_0/id = 0
popup/item_1/text = "Option 2"
popup/item_1/id = 1
popup/item_2/text = "Option 3"
popup/item_2/id = 2
```

---

### RadioButton

Circular radio button. Uses `CheckBox` with a `ButtonGroup` to make options mutually exclusive.

```gdscript
var group = ButtonGroup.new()

var a = CheckBox.new()
a.theme_type_variation = &"RadioButton"
a.button_group = group
a.button_pressed = true   # pre-select
a.text = "Option A"

var b = CheckBox.new()
b.theme_type_variation = &"RadioButton"
b.button_group = group
b.text = "Option B"
```

In `.tscn` files, declare `ButtonGroup` as a sub-resource:

```
[sub_resource type="ButtonGroup" id="MyGroup"]

[node name="RadioA" type="CheckBox" ...]
theme_type_variation = &"RadioButton"
button_group = SubResource("MyGroup")
button_pressed = true
text = "Option A"
```

---

### Win95Checkbox

Square checkbox with a Win95 pixel-art checkmark. Independent toggle — no `ButtonGroup`.

```gdscript
var cb = CheckBox.new()
cb.theme_type_variation = &"Win95Checkbox"
cb.text = "Enable feature"
```

---

## Layout conventions

### Full window layout

```
Panel (root)
└── VBoxContainer "Layout"         anchors_preset = 15 (full rect)
    ├── Panel "MenuBar"            theme_type_variation = "Win95MenuBar"
    │     custom_minimum_size = (0, 22)
    └── Control "WorkArea"         size_flags_vertical = EXPAND
        └── Panel "Window"         theme_type_variation = "WindowPanel"
            └── VBoxContainer      2 px inset all sides
                ├── Panel          theme_type_variation = "TitleBarActive"
                │     custom_minimum_size = (0, 20)
                ├── Panel          content area, size_flags_vertical = EXPAND
                └── Panel          status bar, custom_minimum_size = (0, 20)
```

### Labels with autowrap

Any `Label` with `autowrap_mode` set must also have `custom_minimum_size = Vector2(1, 0)` inside a container, or Godot will log a layout warning.

---

## File structure

```
fonts/
  W95FA.otf                                Win95-accurate bitmap font

theme/
  webcore_theme.tres                       master Theme resource — set in project.godot
  ThemeSetup.gd                            autoload — registers all type variations at runtime

  button/
    button_normal.png                      9×9 raised bevel texture
    button_pressed.png                     9×9 sunken bevel texture
    button_normal_texture.tres             StyleBoxTexture, content margin H=6 V=4
    button_pressed_texture.tres
    button_titlebar_normal_texture.tres    compact variant, content margin H=4 V=2
    button_titlebar_pressed_texture.tres

  panel/
    panel_bg.png
    panel_style.tres

  window/
    window_bg.png
    window_style.tres

  titlebar/
    titlebar_active.png                    3×3 solid #000080
    titlebar_inactive.png                  3×3 solid #808080
    titlebar_style_active.tres
    titlebar_style_inactive.tres

  menubar/
    menubar_bg.png                         bottom-edge separator pixel
    menubar_style.tres

  lineedit/
    lineedit_bg.png                        3×3 sunken border (dark TL / light BR)
    lineedit_style.tres                    StyleBoxTexture, content margin H=4 V=2

  dropdown/
    dropdown_arrow.png                     9×5 RGBA down-triangle icon
    dropdown_style.tres                    StyleBoxTexture — same inset look as lineedit

  radiobutton/
    radio_unchecked.png                    13×13 RGBA circle, dark TL / white BR arc
    radio_checked.png                      same + black 3×3 center dot

  checkbox/
    checkbox_unchecked.png                 13×13 RGBA square, 2 px inset border
    checkbox_checked.png                   same + pixel-art checkmark

  fonts/
    W95FA_spaced.tres                      FontVariation — default body font, spacing_glyph = 1
    W95FA_section.tres                     FontVariation — bold section headings
```

---

## Adding a new component

1. Create a subdirectory `theme/<component>/`.
2. Add PNG textures. No anti-aliasing, no sub-pixel rendering.
3. Create a `StyleBoxTexture` `.tres` in that folder referencing the PNG.
4. Add `[ext_resource]` entries and property bindings to `webcore_theme.tres`.
5. If the variation name is custom, add `theme.set_type_variation()` to `ThemeSetup.gd`.
6. Use `theme_type_variation = &"YourName"` on the node.

**Step 5 is easy to forget.** Every custom variation name that does not match a Godot built-in class must be registered in `ThemeSetup.gd` or it will have no effect at runtime.

Variation names must not match any Godot built-in class name. Prefix with `Win95` when the name would conflict (e.g. `Win95MenuBar` not `MenuBar`, `Win95Checkbox` — note `CheckBox` is the base type, not the variation name).
