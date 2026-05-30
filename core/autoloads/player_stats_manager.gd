extends Node

signal energy_changed(current_energy: float, max_energy: float)
signal energy_exhausted()

var max_energy: float = 100.0
var energy: float = 100.0

func _ready() -> void:
	energy = max_energy

# Consome energia e retorna verdadeiro se foi possível consumir
func consume_energy(amount: float) -> bool:
	if energy <= 0:
		energy_exhausted.emit()
		return false
		
	energy -= amount
	if energy <= 0:
		energy = 0
		energy_exhausted.emit()
		
	energy_changed.emit(energy, max_energy)
	return true

# Restaura uma quantia de energia (comida ou outro meio)
func restore_energy(amount: float) -> void:
	energy = min(energy + amount, max_energy)
	energy_changed.emit(energy, max_energy)

# Restaura toda a energia (ao dormir ou passar o dia)
func restore_full_energy() -> void:
	energy = max_energy
	energy_changed.emit(energy, max_energy)
