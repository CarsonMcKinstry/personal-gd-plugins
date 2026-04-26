class_name StateNode
extends Node 

signal transition_requested(node: StateNode)

var _context: StateContext

#region virtual

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _on_unhandled_input(event: InputEvent) -> StateNode:
	return null

func _on_input(event: InputEvent) -> StateNode:
	return null
	
func _on_process(delta: float) -> StateNode:
	return null
	
func _on_process_physics(delta: float) -> StateNode:
	return null

#endregion

#region protected

func transition_to(node: StateNode) -> void:
	transition_requested.emit.call_deferred(node)	

#endregion

#region internal
	
func _initialize(context: StateContext) -> void:
	_context = context
	process_mode = PROCESS_MODE_DISABLED
	
#endregion
