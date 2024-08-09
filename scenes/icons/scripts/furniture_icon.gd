extends SubViewport
class_name DeviceIcon

var is_ready: bool = false

# The GLB file to load at runtime
@export_file("*.glb") var object_path: String = "":
    set(value):
        object_path = value
        if not is_inside_tree() or object_path == "":
            return

        load_object_path()


func load_object_path():
    if object_path == "":
        return

    var previous_child = find_child("InstObject")
    if previous_child != null:
        print("Clearing previous object")
        previous_child.queue_free()

    print("DeviceIcon: Attempting to load object_path '%s'" % object_path)
    var res: PackedScene = load(object_path)
    if res == null:
        print("DeviceIcon: unable to load %s" % object_path)
        return

    var obj: Node3D = res.instantiate()
    obj.position = Vector3(0, 0, 0)
    obj.name = "InstObject"
    add_child(obj)
    is_ready = true


func _ready() -> void:
    load_object_path()


func _process(delta: float) -> void:
    if is_ready:
        ($InstObject as Node3D).rotate(Vector3.UP, delta)
