extends CanvasLayer
class_name LinkMenu

@export var rule: Dictionary = {}:
    set(value):
        rule = value
        if is_inside_tree():
            update_ui()

@onready var rule_line = preload("res://scenes/ui/rule_line.tscn")
@onready var default_rule_line = preload("res://scenes/ui/default_rule_line.tscn")
@onready var rule_line_label: Label = %LinkID
@onready var rule_container: VBoxContainer = %Container

var current_line: RuleLine = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if rule != {} and is_inside_tree():
        update_ui()


func update_ui():
    if rule != {}:
        rule_line_label.text = "Rule #%d" % rule["id"]

        if current_line != null:
            current_line.queue_free()

        current_line = rule_line.instantiate()
        current_line.rule = rule
        rule_container.add_child(current_line)
    else:
        rule_line_label.text = "Rule ??"

        if current_line != null:
            current_line.queue_free()


func _on_add_rule_button_pressed() -> void:
    var line: Node = default_rule_line.instantiate()
    rule_container.add_child(line)
