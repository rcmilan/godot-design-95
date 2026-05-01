extends Node

# Registers custom theme type variations so that theme_type_variation works
# correctly on Panel/Label nodes at runtime.  Must run as an autoload so it
# executes before any scene node resolves its theme cache.
func _ready() -> void:
	var theme := ThemeDB.get_project_theme()
	if not theme:
		return
	theme.set_type_variation(&"WindowPanel",      &"Panel")
	theme.set_type_variation(&"TitleBarActive",   &"Panel")
	theme.set_type_variation(&"TitleBarInactive", &"Panel")
	theme.set_type_variation(&"TitleBarLabel",    &"Label")
	theme.set_type_variation(&"TitleBarButton",   &"Button")
	theme.set_type_variation(&"Win95MenuBar",      &"Panel")
	theme.set_type_variation(&"SectionLabel",     &"Label")
	theme.set_type_variation(&"RadioButton",      &"CheckBox")
	theme.set_type_variation(&"Win95Checkbox",    &"CheckBox")
