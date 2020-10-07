extends Control

const VARIABLE_TYPES = {
	"INT": "INT",
	"FLOAT": "FLOAT",
	"STRING": "STRING",
	"BOOL": "BOOL"
}

var dialogue_node: Resource = preload("res://entities/DialogueNode.tscn")
var global_variable: Resource = preload("res://entities/GlobalVariable.tscn")
var save_file_picker: Resource = preload("res://entities/SaveFilePicker.tscn")

onready var editor: GraphEdit = $MarginContainer/HBoxContainer/EditorContainer/GraphEdit

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	# Add node by button
	$MarginContainer/HBoxContainer/ToolBar/AddNodeButton.connect("pressed", self, "_on_add_node_button_pressed")
	
	# Filesystem
	$MarginContainer/HBoxContainer/ToolBar/SaveButton.connect("pressed", self, "_on_save_button_pressed")
	$MarginContainer/HBoxContainer/ToolBar/LoadButton.connect("pressed", self, "_on_load_button_pressed")
	
	# Global variables
	$MarginContainer/HBoxContainer/ToolBar/AddVariableButton/Button.connect("pressed", self, "_on_add_variable_button_pressed")
	
	# Quit
	$MarginContainer/HBoxContainer/ToolBar/QuitButton.connect("pressed", self, "_on_quit_button_pressed")

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("control"):
		# Add new node
		if Input.is_action_just_pressed("enter"):
			var dialogue_node_instance: GraphNode = dialogue_node.instance()
			editor.add_child(dialogue_node_instance)
		
		# Zoom editor
		if event.is_action_pressed("zoom_in"):
			editor.zoom += 0.1
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("zoom_out"):
			editor.zoom -= 0.1
			get_tree().set_input_as_handled()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_add_node_button_pressed() -> void:
	var dialogue_node_instance: GraphNode = dialogue_node.instance()
	editor.add_child(dialogue_node_instance)

func _on_save_button_pressed() -> void:
	var result: Dictionary = _parse_global_options()
	result["dialogue"] = _parse_dialogue_nodes()
	
	var save_file_picker_instance: FileDialog = save_file_picker.instance()
	save_file_picker_instance.save_data = result
	add_child(save_file_picker_instance)

func _on_load_button_pressed() -> void:
	# TODO add fs dialogue picker
	pass

func _on_add_variable_button_pressed() -> void:
	var global_variable_instance: VBoxContainer = global_variable.instance()
	$MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.add_child(global_variable_instance)

# TODO debug only, add a popup dialogue later?
func _on_quit_button_pressed() -> void:
	get_tree().quit()

###############################################################################
# Private functions                                                           #
###############################################################################

func _parse_global_options() -> Dictionary:
	"""
	Parse global options from the toolbar.
	"""
	print_debug("Parsing global options")

	var result: Dictionary = {}
	
	result["name"] = $MarginContainer/HBoxContainer/ToolBar/TitleContainer/LineEdit.text
	result["initial_dialogue_node"] = $MarginContainer/HBoxContainer/ToolBar/InitialNodeContainer/LineEdit.text
	
	var variables: Dictionary = {}
	for v in $MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.get_children():
		var variable_type: String = v.get_node("Type").get_node("LineEdit").text
		
		variables[v.get_node("Name").get_node("LineEdit").text] = {
			"type": variable_type,
			"value": _convert_variable_to_type(v.get_node("Value").get_node("LineEdit").text, variable_type)
		}
	
	result["variables"] = variables
	
	print_debug("Finished parsing global options")
	
	return result

func _parse_dialogue_nodes() -> Dictionary:
	"""
	Loop through all dialogue nodes and parse all options.
	"""
	print_debug("Parsing dialogue nodes")
	
	var result: Dictionary = {}
	
	for n in editor.get_children():
		if n is GraphNode:
			var dialogue: Dictionary = {}
			dialogue["node_text"] = n.get_node("Text").get_node("TextEdit").text
			dialogue["should_end"] = n.get_node("ShouldEnd").get_node("CheckBox").pressed
			dialogue["choices"] = _parse_choices(n.get_node("Choices").get_children())
			dialogue["on_enter_set_variables"] = _parse_enter_exit_variables(n.get_node("OnEnterSetVariables").get_children())
			dialogue["on_enter_functions"] = _parse_enter_exit_functions(n.get_node("OnEnterFunctions").get_children())
			
			result[n.get_node("Name").get_node("LineEdit").text] = dialogue
	
	print_debug("Finshed parsing dialogue nodes")
	
	return result

func _parse_choices(choices: Array) -> Array:
	"""
	Parse each choice and return an Array of Dictionaries.
	"""
	var result: Array = []
	
	for c in choices:
		var choice: Dictionary = {}
		choice["choice_name"] = c.get_node("Name").get_node("LineEdit").text
		choice["removable"] = c.get_node("Removable").get_node("CheckBox").pressed
		choice["next_node"] = c.get_node("NextNode").get_node("LineEdit").text
		choice["conditional"] = c.get_node("Conditional").get_node("CheckBox").pressed
		choice["conditional_variables"] = _parse_conditional_variables(c.get_node("ConditionalVariables").get_children())
		choice["on_exit_set_variables"] = _parse_enter_exit_variables(c.get_node("OnExitSetVariables").get_children())
		choice["on_exit_functions"] = _parse_enter_exit_functions(c.get_node("OnExitFunctions").get_children())
		
		result.append(choice)
	
	return result

func _parse_conditional_variables(conditional_variables: Array) -> Dictionary:
	var result: Dictionary = {}
	
	for c in conditional_variables:
		var conditional: Dictionary = {}
		var conditional_name: String = c.get_node("Name").get_node("LineEdit").text
		conditional["operator"] = c.get_node("Operator").get_node("LineEdit").text
		
		for child in $MarginContainer/HBoxContainer/ToolBar/ScrollContainer/VariablesContainer.get_children():
			if conditional_name == child.get_node("Name").get_node("LineEdit").text:
				conditional["value"] = _convert_variable_to_type(c.get_node("Value").get_node("LineEdit").text, child.get_node("Type").get_node("LineEdit").text)
			else:
				printerr("Conditional variable not found in Global Variable context")
		
		result[conditional_name] = conditional
	
	return result

func _parse_enter_exit_variables(variables: Array) -> Dictionary:
	var result: Dictionary = {}
	
	for v in variables:
		result[v.get_node("Name").get_node("LineEdit").text] = v.get_node("Value").get_node("LineEdit").text
	
	return result

func _parse_enter_exit_functions(functions: Array) -> Dictionary:
	var result: Dictionary = {}
	
	for f in functions:
		var params: Array = []
		for p in f.get_node("Params").get_children():
			params.append(_convert_variable_to_type(p.get_node("Value").get_node("LineEdit").text, p.get_node("Type").get_node("LineEdit").text))
		
		result[f.get_node("Function").get_node("LineEdit").text] = params
	
	return result

func _convert_variable_to_type(value, type: String):
	match type:
		VARIABLE_TYPES.INT:
			return int(value)
		VARIABLE_TYPES.FLOAT:
			return float(value)
		VARIABLE_TYPES.STRING:
			return str(value)
		VARIABLE_TYPES.BOOL:
			return bool(value)

###############################################################################
# Public functions                                                            #
###############################################################################


