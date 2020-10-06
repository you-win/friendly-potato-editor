extends Control

var dialogue_node: Resource = preload("res://entities/DialogueNode.tscn")
var global_variable: Resource = preload("res://entities/GlobalVariable.tscn")

onready var editor: GraphEdit = $MarginContainer/MarginBackground/HBoxContainer/EditorContainer/ColorRect/GraphEdit

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	# Add node by button
	$MarginContainer/MarginBackground/HBoxContainer/ToolBar/AddNodeButton.connect("pressed", self, "_on_add_node_button_pressed")
	
	# Filesystem
	$MarginContainer/MarginBackground/HBoxContainer/ToolBar/SaveButton.connect("pressed", self, "_on_save_button_pressed")
	$MarginContainer/MarginBackground/HBoxContainer/ToolBar/LoadButton.connect("pressed", self, "_on_load_button_pressed")
	
	# Global variables
	$MarginContainer/MarginBackground/HBoxContainer/ToolBar/AddVariableButton/Button.connect("pressed", self, "_on_add_variable_button_pressed")
	
	# Quit
	$MarginContainer/MarginBackground/HBoxContainer/ToolBar/QuitButton.connect("pressed", self, "_on_quit_button_pressed")

func _input(event: InputEvent) -> void:
	if(Input.is_action_pressed("control") and Input.is_action_just_pressed("enter")):
		var dialogue_node_instance: GraphNode = dialogue_node.instance()
		editor.add_child(dialogue_node_instance)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_add_node_button_pressed() -> void:
	var dialogue_node_instance: GraphNode = dialogue_node.instance()
	editor.add_child(dialogue_node_instance)

func _on_save_button_pressed() -> void:
	var result: Dictionary = _parse_global_options()
	result["dialogue"] = _parse_dialogue_nodes()
	
	# TODO add fs dialogue save box

func _on_load_button_pressed() -> void:
	# TODO add fs dialogue picker
	pass

func _on_add_variable_button_pressed() -> void:
	var global_variable_instance: VBoxContainer = global_variable.instance()
	$MarginContainer/MarginBackground/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.add_child(global_variable_instance)

# TODO debug only, add a popup dialogue later?
func _on_quit_button_pressed() -> void:
	get_tree().quit()

###############################################################################
# Private functions                                                           #
###############################################################################

func _parse_dialogue_nodes() -> Dictionary:
	var result: Dictionary = {}
	
	return result

func _parse_global_options() -> Dictionary:
	var result: Dictionary = {}
	
	return result

###############################################################################
# Public functions                                                            #
###############################################################################


