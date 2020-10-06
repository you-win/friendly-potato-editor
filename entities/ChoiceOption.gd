extends VBoxContainer

var conditional_variable: Resource = preload("res://entities/ConditionalVariable.tscn")
var variable: Resource = preload("res://entities/SetVariable.tscn")
var function: Resource = preload("res://entities/Function.tscn")

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	$ConditionalVariablesButton/Button.connect("pressed", self, "_on_conditional_button_pressed")
	$OnExitSetVariablesButton/Button.connect("pressed", self, "_on_variables_button_pressed")
	$OnExitFunctionsButton/Button.connect("pressed", self, "_on_functions_button_pressed")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_conditional_button_pressed() -> void:
	var conditional_variable_instance: VBoxContainer = conditional_variable.instance()
	$ConditionalVariables.add_child(conditional_variable_instance)

func _on_variables_button_pressed() -> void:
	var variable_instance: VBoxContainer = variable.instance()
	$OnExitSetVariables.add_child(variable_instance)

func _on_functions_button_pressed() -> void:
	var function_instance: VBoxContainer = function.instance()
	$OnExitFunctions.add_child(function_instance)

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################


