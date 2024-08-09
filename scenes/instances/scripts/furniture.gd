extends Node3D
class_name InstantiatedDevice
# A device is an object placed by the user in the world.
# It has a connection ball that can be used to create rules

@export_file("*.glb") var object_file : String
@export var device_name: String = "Name"

var selected: bool = false
var object: Node3D = null

@onready var UI_viewport = $SelectionBall/pivot/viewport
@onready var viewport_pivot = $SelectionBall/pivot
@onready var selectionBall = $SelectionBall

func set_furn_name():
    $SelectionBall/pivot/viewport/Viewport/CanvasLayer.device_name = device_name

func _ready():
    # Connect the delete signal from the UI_viewport to the deletion callback
    UI_viewport.connect_scene_signal("delete_me", _on_delete_me)
    set_furn_name.call_deferred()
    set_view_port(false)  # Disable by default, only enable when the object is selected

    # Global signal to deselect everything
    Globals.obj_selected.connect(_on_deselected)

    if object_file != null:
        object = load(object_file).instantiate()
        add_child(object)
        var children = object.find_children("*", "MeshInstance3D")
        # Find highest child
        var max_height = 0
        for child in children:
            var height = (child as MeshInstance3D).get_aabb().end.y
            if height > max_height:
                max_height = height

        if max_height < 1.6:
            selectionBall.position.y = (max_height + 0.2)
        else:
            selectionBall.position.y = 1.8
            selectionBall.position.x = 0.5


func _process(_delta):
    viewport_pivot.look_at(Globals.player_position)


func set_view_port(status: bool) -> void:
    UI_viewport.enabled = status
    UI_viewport.visible = status


func get_selected() -> bool:
    return selected


func _on_selected():
    if not selected:
        selected = true
        set_view_port(true)


func _on_deselected():
    if selected:
        selected = false
        set_view_port(false)


func _on_placement():
    # Find the child of object that is a StaticBody3D and change its collision layer to 21
    var children = object.find_children("*", "CollisionObject3D") as Array[StaticBody3D]
    for child in children:
        (child as StaticBody3D).set_collision_layer_value(21, true)


# Called when the user presses on the delete button
func _on_delete_me():
    queue_free()
