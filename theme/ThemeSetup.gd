extends Node

# Registers custom type variations — the only thing .tres files cannot express.
# All style data lives in webcore_theme.tres. This autoload exists solely to run
# Theme.set_type_variation() before any scene node resolves its theme cache.
func _ready() -> void:
	var theme := ThemeDB.get_project_theme()
	if not theme:
		return
	theme.set_type_variation(&"WindowPanel",      &"Panel")
	theme.set_type_variation(&"TitleBarActive",   &"Panel")
	theme.set_type_variation(&"TitleBarInactive", &"Panel")
	theme.set_type_variation(&"TitleBarLabel",    &"Label")
	theme.set_type_variation(&"TitleBarButton",   &"Button")
	theme.set_type_variation(&"Win95MenuBar",     &"Panel")
	theme.set_type_variation(&"SectionLabel",     &"Label")
	theme.set_type_variation(&"RadioButton",      &"CheckBox")
	theme.set_type_variation(&"Win95Checkbox",    &"CheckBox")
	theme.set_type_variation(&"Win95Dropdown",    &"OptionButton")
