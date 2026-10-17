extends Resource
class_name Dialogue

@export var speaker : String
@export_custom(PROPERTY_HINT_MULTILINE_TEXT,"Dialogue") var text : String
@export_range(1, 5, 1) var textSpeed : float = 1.0
@export var allowSkipAt : float = 1.0
