class_name VitalResource
extends Node

## Emitted whenever the value changes. Useful for connecting to UI ProgressBars.
signal value_changed(current: float, maximum: float)

## Emitted when the resource hits exactly 0.
signal depleted()

## Emitted when the resource reaches its maximum capacity.
signal maxed_out()

@export var max_value: float = 100.0:
	set(value):
		# Prevent negative max values
		max_value = max(0.0, value)
		# Trigger the current_value setter to ensure it doesn't exceed the new max
		current_value = current_value 

@export var initial_value: float = 100.0

# The actual resource value. Modifying this directly is safe because of the setter below.
var current_value: float:
	set(value):
		var old_value = current_value
		# Clamp enforces the value stays strictly between 0 and max_value
		current_value = clamp(value, 0.0, max_value)
		
		# Only emit signals if the value actually changed
		if current_value != old_value:
			value_changed.emit(current_value, max_value)
			
			if current_value == 0.0:
				depleted.emit()
			elif current_value == max_value:
				maxed_out.emit()

func _ready() -> void:
	# Set the initial value on startup.
	self.current_value = initial_value

## Increases the resource by a specific amount.
func add(amount: float) -> void:
	self.current_value += amount

## Decreases the resource by a specific amount.
func subtract(amount: float) -> void:
	self.current_value -= amount

## Completely fills the resource.
func fill() -> void:
	self.current_value = max_value

## Completely empties the resource.
func empty() -> void:
	self.current_value = 0.0
