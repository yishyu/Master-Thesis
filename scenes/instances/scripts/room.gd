extends Node3D
class_name InstantiatedRoom

@export var room_name: String:
    set(value):
        room_name = value
        set_room_name.call_deferred()

@export var object_file : PackedScene
@export var room_id: int = 0

var selected: bool = false
var object: Node3D = null

@onready var room_menu: Node3D = %RoomMenu

func set_room_name() -> void:
    ($"../pivot/RoomMenu/Viewport/RoomInfo" as RoomMenu).room_name = room_name


func _ready() -> void:
    # Connect the delete signal from the UIViewPort to the deletion callback
    room_menu.connect_scene_signal("hide", _on_hide_room)
    room_menu.connect_scene_signal("delete", _on_delete_room)
    room_menu.connect_scene_signal("save", _on_save_room)

    if object_file != null:
        object = object_file.instantiate()
        add_child(object)

    set_room_name.call_deferred()


func _on_hide_room() -> void:
    # Simply delete the node from the scene
    Globals.delete_room.emit(room_id)


func _on_delete_room() -> void:
    # TODO: Ask for confirmation
    print("Asking confirmation and then deleting room")
    pass


func _on_save_room() -> void:
    print("Saving room as ...")
    pass


# Finds a device in the current room, given it's object_path
# If multiple device with the same object_path exist, the first one will be
# returned
func find_device_in_room(object_path: String) -> InstantiatedDevice:
    print("searchin for '%s'" % object_path)

    print("Children")
    var _child = get_children()[0]
    for child_child in _child.get_children():
        print("%s - %s" % [child_child.name, child_child is InstantiatedDevice])

    var children = get_children()[0].find_children("*", "InstantiatedDevice")
    print("Found %d InstantiatedDevices" % len(children))
    for child in children:
        print("Iterating in %s" % room_id)
        if (child as InstantiatedDevice).object_file == object_path:
            return child
    print("Not found")
    return null
