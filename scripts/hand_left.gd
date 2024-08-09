extends XRController3D
class_name LeftHand

@onready var controller : XRController3D = XRHelpers.get_xr_controller(self)

var menu_opened: bool = false

signal switchdom

# Wether this hand is currently dominant
var dominant: bool = false :
	set(value):  # Ensure the laser is switched accordingly
		dominant = value
		$Pointer.enabled = dominant
		$Pointer.show_laser = dominant

# Called when the node enters the scene tree for the first time.
func _ready():
	set_menu_enabled(menu_opened)


func set_menu_enabled(status) -> void:
	%HandMenu.enabled = status
	%HandMenu.visible = status


func _on_button_pressed(button):
	match button:
		"ax_button":
			menu_opened = not menu_opened

	set_menu_enabled(menu_opened)

	if button == "trigger_click" and !dominant:  # Make the hand dominant
		switchdom.emit()
