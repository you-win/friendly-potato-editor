extends VBoxContainer

var function_parameter: Resource = preload("res://entities/FunctionParameter.tscn")

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	$Button.connect("pressed", self, "_on_button_pressed")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_button_pressed() -> void:
	var function_parameter_instance: VBoxContainer = function_parameter.instance()
	$Params.add_child(function_parameter_instance)

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################


