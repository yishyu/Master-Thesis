extends CanvasLayer
class_name HandMenu


@onready var room_scene: PackedScene = preload("res://scenes/ui/runtime_room_button_subview.tscn")
@onready var device_scene: PackedScene = preload("res://scenes/ui/runtime_device_button_subview.tscn")
@onready var rules_tree: PackedScene = preload("res://scenes/ui/rules_tree.tscn")

func _ready():
    for room in Globals.get_rooms():
        # Instantiate the correct scene
        var button_scene: RuntimeRoomButtonSubview = room_scene.instantiate()
        button_scene.id = room["id"]
        button_scene.name = room["name"]
        button_scene.path = room["path"]
        %Rooms.add_child(button_scene)
        button_scene.attach_button_signal(_on_button_room_pressed)

    for device in Globals.get_devices():
        var button_scene: RuntimeDeviceButtonSubview = device_scene.instantiate()
        button_scene.name = "%s (%s)" % [device["d_name"], device["r_name"]]
        button_scene.path = device["d_path"]
        button_scene.device_instance_id = device["id"]
        button_scene.room = {
            "id": device["r_id"],
            "name": device["r_name"],
            "path": device["r_path"]
        }

        %Devices.add_child(button_scene)
        button_scene.attach_button_signal(_on_button_device_pressed)

    # Shows a list of rooms with checkboxes on their side.
    var rules_scene: Node = rules_tree.instantiate()
    %Rules.add_child(rules_scene)


# These simply carry the signal up to the main script
func _on_button_device_pressed(room: Dictionary, device_id: int):
    Globals.spawn_device.emit(room, device_id)


func _on_button_room_pressed(room: Dictionary):
    Globals.spawn_room.emit(room)
