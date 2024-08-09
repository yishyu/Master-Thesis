extends XRToolsInteractableBody
class_name Connection

@export_color_no_alpha var link_color
@export_color_no_alpha var selected_link_color

@export var first_element: Node3D = null
@export var second_element: Node3D = null

@onready var arrow: Node3D = $Arrow
@onready var arrow_mesh: MeshInstance3D = $Arrow/Connection/Cylinder
@onready var collision_shape: CollisionShape3D = $Arrow/Connection/CollisionShape3D

@onready var rule_viewport = $ViewPortPivot/ViewPort
@onready var rule_viewport_pivot: Node3D = $ViewPortPivot

var selected: bool = false :
    set(value):
        selected = value
        set_outline(selected)  # Hide or show the menu + colored link


var placed: bool = false :
    set(value):
        placed = value
        collision_shape.disabled = not placed

@export var rule: Dictionary = {}:
    set(value):
        rule = value
        if is_inside_tree():
            update_ui()


func _ready() -> void:
    if Globals.obj_selected.connect(_on_object_selected) != OK:
        print("Can't connect global on object selected to link")
    arrow_mesh.mesh = arrow_mesh.mesh.duplicate()
    arrow_mesh.mesh.surface_set_material(0, StandardMaterial3D.new())
    arrow_mesh.mesh.surface_get_material(0).set("albedo_color", link_color)
    set_outline(selected)
    update_ui()


func update_ui():
    # Update the link menu UI by passing the "rule" element
    ($ViewPortPivot/ViewPort/Viewport/LinkMenu as LinkMenu).rule = rule


func _process(_delta: float) -> void:
    if is_instance_valid(first_element) and is_instance_valid(second_element) and first_element != null and second_element != null:
        # Set transform according to the two points coordinates
        var distance: float = first_element.global_position.distance_to(second_element.global_position)
        arrow.scale.z = distance
        arrow.scale.x = 0.25 * distance
        arrow.scale.y = 0.25 * distance

        arrow.look_at_from_position(first_element.global_position, second_element.global_position, Vector3.LEFT)
        rule_viewport_pivot.global_position = (first_element.global_position + second_element.global_position) / 2 + Vector3.UP * (distance / 2)
        rule_viewport_pivot.scale = Vector3(distance, distance, distance)
        rule_viewport_pivot.look_at(Globals.player_position)
    elif !is_instance_valid(first_element) or !is_instance_valid(second_element):
        # TODO: Notify user that the link was destroyed
        queue_free()


func set_outline(_selected: bool) -> void:
    arrow_mesh.mesh.surface_get_material(0).set("albedo_color", selected_link_color if _selected else link_color)
    rule_viewport.enabled = selected
    rule_viewport.visible = selected


func _on_object_selected() -> void:
    selected = false


func _on_pointer_event(event: XRToolsPointerEvent) -> void:
    match event.event_type:
        XRToolsPointerEvent.Type.ENTERED:
            set_outline(true)
        XRToolsPointerEvent.Type.EXITED:
            set_outline(selected)
        XRToolsPointerEvent.Type.PRESSED:
            Globals.obj_selected.emit()
            selected = true
