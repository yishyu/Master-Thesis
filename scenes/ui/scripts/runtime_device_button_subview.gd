extends VBoxContainer
class_name RuntimeDeviceButtonSubview

@onready var device_button: Button = %Button
@onready var view: DeviceIcon = %View

@export var device_instance_id: int = -1
@export var path: String :
    set(value):
        path = value
        if is_inside_tree():
            view.object_path = path

# Information about the room the device is in
@export var room: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    device_button.text = name
    if path == null:
        print("DeviceIcon: Path is null")
    view.object_path = path


# Attached the button `button_down` signal to the given callable
func attach_button_signal(cb: Callable):
    var res = device_button.button_down.connect(cb.bind(room, device_instance_id))
    if res != OK:
        print("Unable to connect button signal from %s (code: %d)" % [name, res])
