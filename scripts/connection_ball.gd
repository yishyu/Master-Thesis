extends XRToolsInteractableBody
class_name SelectionBall

signal gets_selected

@export_color_no_alpha var standard_color = Color(1, 1, 1)
@export_color_no_alpha var selected_color = Color(0, 0.9, 0.9)

@onready var ball_mesh: MeshInstance3D = $BallMesh

func _ready():
    ball_mesh.mesh = ball_mesh.mesh.duplicate()
    ball_mesh.mesh.set("material", StandardMaterial3D.new())
    ball_mesh.mesh.set("material/albedo_color", standard_color)


func _on_pointer_event(event : XRToolsPointerEvent) -> void:
    match event.event_type:
        XRToolsPointerEvent.Type.ENTERED:
            ball_mesh.mesh.material.albedo_color = selected_color
        XRToolsPointerEvent.Type.EXITED:
            ball_mesh.mesh.material.albedo_color = standard_color if not is_selected() else selected_color
        XRToolsPointerEvent.Type.PRESSED:
            Globals.obj_selected.emit()
            gets_selected.emit()


func is_selected() -> bool:
    return (get_parent() as InstantiatedDevice).get_selected()
