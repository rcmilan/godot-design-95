# design-95

A Windows 95-style UI design system for Godot 4. All components are theme-driven — no per-node overrides. Pixel-accurate 9-slice textures, nearest-neighbour filtering.

---

## For coding agents

This repository is the **source of truth** for the design system. When building a project that uses this system, copy the required files and follow the instructions below exactly.

---

## Setup

### 1. Copy files into your project

Copy these directories and files into the root of your Godot project:

```
fonts/
theme/
```

The `fonts/` directory contains `W95FA.otf` (the Win95-accurate bitmap font).
The `theme/` directory contains all style resources, textures, and the autoload script.

### 2. Register the theme in project.godot

Add these entries to your `project.godot`:

```ini
[autoload]
ThemeSetup="*res://theme/ThemeSetup.gd"

[gui]
theme/custom="res://theme/webcore_theme.tres"

[rendering]
textures/canvas_textures/default_texture_filter=0
```

`textures/canvas_textures/default_texture_filter=0` is mandatory — it sets nearest-neighbour filtering globally so pixel textures render without blur.

### 3. Why the autoload is required

Godot 4 does not allow custom `theme_type_variation` names to be registered inside `.tres` files. They must be registered at runtime via `Theme.set_type_variation()`. `ThemeSetup.gd` runs as an autoload so it executes before any scene node resolves its theme cache. **Without it, all custom components will render with default Godot styles.**

---

## Components

Every component is a standard Godot node with `theme_type_variation` set. No custom scripts are required for appearance.

---

### Button

Standard raised Win95 button. Uses 9-slice pixel textures for normal and pressed states.

```gdscript
# Node type: Button
# No theme_type_variation needed — Button is styled globally.

var btn = Button.new()
btn.text = "OK"
```

---

### TitleBarButton

Compact button variant for use inside title bars. Reduced vertical padding so it fits within the 20 px title bar height.

```gdscript
# Node type: Button
var btn = Button.new()
btn.theme_type_variation = &"TitleBarButton"
btn.custom_minimum_size = Vector2(16, 0)
btn.text = "_"
```

---

### Panel

Generic gray background panel. Win95-style raised bevel border.

```gdscript
# Node type: Panel
# No theme_type_variation needed — Panel is styled globally.
var panel = Panel.new()
```

---

### WindowPanel

Raised bevel panel intended as the outer container of a window. Use with a `VBoxContainer` inside for layout.

```gdscript
# Node type: Panel
var win = Panel.new()
win.theme_type_variation = &"WindowPanel"
```

Typical window structure:

```
Panel (WindowPanel)
└── VBoxContainer          # 2 px inset on all sides
    ├── Panel (TitleBarActive)
    ├── Panel              # content area
    └── Panel              # status bar
```

---

### TitleBarActive / TitleBarInactive

Solid-fill panels for window title bars. `TitleBarActive` is navy blue (#000080). `TitleBarInactive` is gray (#808080). Recommended height: 20 px via `custom_minimum_size`.

```gdscript
var bar = Panel.new()
bar.theme_type_variation = &"TitleBarActive"   # or &"TitleBarInactive"
bar.custom_minimum_size = Vector2(0, 20)
```

Title bar label text is white. Use a `Label` with `theme_type_variation = &"TitleBarLabel"` inside the title bar. Window control buttons use `TitleBarButton`.

Full title bar pattern:

```
Panel (TitleBarActive)              custom_minimum_size = (0, 20)
└── HBoxContainer                   anchors fill parent, left offset = 4
    ├── Label (TitleBarLabel)       size_flags_horizontal = EXPAND
    │     text = "window title"
    └── HBoxContainer               window buttons
        ├── Button (TitleBarButton) text = "_",  min_width = 16
        ├── Button (TitleBarButton) text = "□",  min_width = 16
        └── Button (TitleBarButton) text = "X",  min_width = 16
```

---

### Win95MenuBar

Gray top bar with a 1 px dark separator on the bottom edge. Recommended height: 22 px.

```gdscript
var bar = Panel.new()
bar.theme_type_variation = &"Win95MenuBar"
bar.custom_minimum_size = Vector2(0, 22)
```

Note: `"MenuBar"` cannot be used as a variation name because it conflicts with a Godot built-in class. Always use `"Win95MenuBar"`.

---

### SectionLabel

Bold, slightly larger label for section headings inside content panels. Uses a `FontVariation` of W95FA with `variation_embolden = 1.0` at 13 px.

```gdscript
var lbl = Label.new()
lbl.theme_type_variation = &"SectionLabel"
lbl.text = "Controls"
```

---

### LineEdit

Win95-style sunken text input. Inset border (dark top/left, light bottom/right), white fill. The style is applied globally to all `LineEdit` nodes — no variation needed.

```gdscript
var field = LineEdit.new()
field.placeholder_text = "Type something..."
```

If a `LineEdit` is placed inside a container with `autowrap` concerns, set `custom_minimum_size = Vector2(1, 0)` to avoid layout warnings.

---

### RadioButton

Circular radio button. Uses `CheckBox` with a `ButtonGroup` resource. All `CheckBox` nodes sharing the same `ButtonGroup` become mutually exclusive. Godot automatically switches to the `radio_checked` / `radio_unchecked` icon variants when a `ButtonGroup` is assigned.

```gdscript
var group = ButtonGroup.new()

var a = CheckBox.new()
a.theme_type_variation = &"RadioButton"
a.button_group = group
a.text = "Option A"
a.button_pressed = true   # pre-select

var b = CheckBox.new()
b.theme_type_variation = &"RadioButton"
b.button_group = group
b.text = "Option B"
```

In `.tscn` files, declare the `ButtonGroup` as a sub-resource and reference it:

```gdscript
[sub_resource type="ButtonGroup" id="MyGroup"]

[node name="RadioA" type="CheckBox" ...]
theme_type_variation = &"RadioButton"
button_group = SubResource("MyGroup")
button_pressed = true
text = "Option A"
```

---

### Win95Checkbox

Square checkbox with a Win95 pixel-art checkmark. Independent toggle — no `ButtonGroup`. Uses the `checked` / `unchecked` icon variants (not `radio_*`).

```gdscript
var cb = CheckBox.new()
cb.theme_type_variation = &"Win95Checkbox"
cb.text = "Enable feature"
```

---

## Layout conventions

### Window with content

```
Panel "Main" (root)
└── VBoxContainer "Layout"     anchors_preset = 15 (full rect)
    ├── Panel "MenuBar"        theme_type_variation = "Win95MenuBar"
    │     custom_minimum_size = (0, 22)
    └── Control "WorkArea"     size_flags_vertical = EXPAND
        └── Panel "Window"     theme_type_variation = "WindowPanel"
            └── VBoxContainer  2 px inset all sides
                ├── Panel      theme_type_variation = "TitleBarActive"
                ├── Panel      content area, size_flags_vertical = EXPAND
                └── Panel      status bar, custom_minimum_size = (0, 20)
```

Keep `Win95MenuBar` and `Window` in separate layout containers (not floating siblings) to avoid z-order overlap.

### Autowrapping labels

Any `Label` with `autowrap_mode` set must have `custom_minimum_size = Vector2(1, 0)` when placed inside a container, or Godot will show a layout warning.

---

## File structure

```
fonts/
  W95FA.otf                        pixel-accurate Win95 UI font

theme/
  webcore_theme.tres               master Theme resource (set in project.godot)
  ThemeSetup.gd                    autoload — registers all type variations

  button/
    button_normal.png              9×9 raised bevel
    button_pressed.png             9×9 inverted bevel
    button_normal_texture.tres     StyleBoxTexture, content margin 6/4
    button_pressed_texture.tres
    button_titlebar_normal_texture.tres   compact variant, content margin 4/2
    button_titlebar_pressed_texture.tres

  panel/
    panel_bg.png
    panel_style.tres

  window/
    window_bg.png
    window_style.tres

  titlebar/
    titlebar_active.png            3×3 solid #000080
    titlebar_inactive.png          3×3 solid #808080
    titlebar_style_active.tres
    titlebar_style_inactive.tres

  menubar/
    menubar_bg.png                 bottom separator pixel
    menubar_style.tres

  lineedit/
    lineedit_bg.png                3×3 sunken border
    lineedit_style.tres

  radiobutton/
    radio_unchecked.png            13×13 RGBA circle, dark TL / white BR arc
    radio_checked.png              same + black 3×3 center dot

  checkbox/
    checkbox_unchecked.png         13×13 RGBA square, 2-px inset border
    checkbox_checked.png           same + pixel-art checkmark

  fonts/
    W95FA_spaced.tres              FontVariation — default font, spacing_glyph = 1
    W95FA_section.tres             FontVariation — bold + spacing for SectionLabel
```

---

## Adding new components

1. Generate a PNG texture in `theme/<component>/`. Textures must be RGB or RGBA, no anti-aliasing.
2. Create a `StyleBoxTexture` `.tres` in the same folder referencing the PNG.
3. Add `ext_resource` entries and property bindings to `webcore_theme.tres`.
4. If the variation name is custom (not a Godot built-in class name), add a `theme.set_type_variation()` call in `ThemeSetup.gd`.
5. Use `theme_type_variation = &"YourVariationName"` on the node in the scene.

Variation names must not match any Godot built-in class name (e.g., use `Win95MenuBar` not `MenuBar`, use `Win95Checkbox` — `CheckBox` itself is fine as a base but cannot be a variation target by the same name).
