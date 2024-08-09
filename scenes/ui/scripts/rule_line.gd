extends VBoxContainer
class_name RuleLine

@export var rule: Dictionary = {}:
    set(value):
        rule = value
        if rule != {} and is_inside_tree():
            update_ui()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if rule != {} and is_inside_tree():
        update_ui()


func update_ui():
    var from_device_properties = Globals.get_device_properties(rule["from_device_id_non_instance"] as int)

    (%FromObject/Name as Label).text = "%s (%s)" % [rule["from_device_name"], rule["from_room_name"]]
    for prop in from_device_properties:
        (%FromObject/PropertyName as OptionButton).add_item(prop["name"] as String, prop["id"] as int)

    %FromObject/PropertyStatus.queue_free()

    if rule["from_device_property_type"] == "colorwheel":
        var option: ColorPickerButton = ColorPickerButton.new()
        %FromObject.add_child(option)
    elif rule["from_device_property_type"] == "toggle":
        var option: OptionButton = OptionButton.new()
        option.add_item("on", 0)
        option.add_item("off", 0)
        option.name = "PropertyStatus"
        %FromObject.add_child(option)
    elif rule["from_device_property_type"] == "spinbox":
        var option: SpinBox = SpinBox.new()
        %FromObject.add_child(option)
    elif rule["from_device_property_type"] == "multichoice":
        var option: OptionButton = OptionButton.new()
        option.add_item("first choice...", 1)
        option.add_item("second choice...", 2)
        option.add_item("third choice...", 3)
        %FromObject.add_child(option)

    var to_device_properties = Globals.get_device_properties(rule["to_device_id_non_instance"] as int)

    (%ToObject/Name as Label).text = "%s (%s)" % [rule["to_device_name"], rule["to_room_name"]]
    for prop in to_device_properties:
        (%ToObject/PropertyName as OptionButton).add_item(prop["name"] as String, prop["id"] as int)

    %ToObject/PropertyStatus.queue_free()

    if rule["from_device_property_type"] == "colorwheel":
        var option: ColorPickerButton = ColorPickerButton.new()
        option.name = "PropertyStatus"
        %ToObject.add_child(option)
    elif rule["from_device_property_type"] == "toggle":
        var option: OptionButton = OptionButton.new()
        option.add_item("on", 0)
        option.add_item("off", 0)
        option.name = "PropertyStatus"
        %ToObject.add_child(option)
    elif rule["from_device_property_type"] == "spinbox":
        var option: SpinBox = SpinBox.new()
        option.name = "PropertyStatus"
        %ToObject.add_child(option)
    elif rule["from_device_property_type"] == "multichoice":
        var option: OptionButton = OptionButton.new()
        option.add_item("first choice...", 1)
        option.add_item("second choice...", 2)
        option.add_item("third choice...", 3)
        option.name = "PropertyStatus"
        %ToObject.add_child(option)


func _on_select_rule_button_down() -> void:
    Globals.spawn_rule.emit(rule)
