extends GraphNode

var choice_option: Resource = preload("res://entities/ChoiceOption.tscn")
var variable: Resource = preload("res://entities/SetVariable.tscn")
var function: Resource = preload("res://entities/Function.tscn")

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	$ChoicesButton/Button.connect("pressed", self, "_on_choices_button_pressed")
	$OnEnterSetVariablesButton/Button.connect("pressed", self, "_on_variables_button_pressed")
	$OnEnterFunctionsButton/Button.connect("pressed", self, "_on_functions_button_pressed")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_choices_button_pressed() -> void:
	var choice_option_instance: VBoxContainer = choice_option.instance()
	$Choices.add_child(choice_option_instance)

func _on_variables_button_pressed() -> void:
	var variable_instance: VBoxContainer = variable.instance()
	$OnEnterSetVariables.add_child(variable_instance)

func _on_functions_button_pressed() -> void:
	var function_instance: VBoxContainer = function.instance()
	$OnEnterFunctions.add_child(function_instance)

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################


