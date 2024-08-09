extends SubViewport
## Represents the Icon of a room. An instance of the room rotating infinitely,
## in its own viewport
class_name RoomIcon

var is_ready: bool = false

# The packed scene that will be rendered
@export var object_path: PackedScene = null:
    set(value):
        object_path = value
        if not is_inside_tree() or object_path == null:
            return

        load_object_path()


func load_object_path():
    if object_path == null:
        return

    var previous_child = find_child("InstObject")
    if previous_child != null:
        print("Clearing previous object")
        # make sure it doesn't interfere
        previous_child.name = "deleted_item"
        previous_child.queue_free()

    var obj: Node3D = object_path.instantiate()
    obj.position = Vector3(0, 0, 0)
    obj.name = "InstObject"
    add_child(obj)
    is_ready = true


func _ready() -> void:
    load_object_path()

func _process(delta: float) -> void:
    if is_ready:
        ($InstObject as Node3D).rotate(Vector3.UP, delta)
