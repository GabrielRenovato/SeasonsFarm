extends Node

## Gerencia conexão/desconexão de controles.
## Adiciona mapeamentos SDL para controles não reconhecidos nativamente (ex: ROG Ally).

signal controller_connected(device_id: int, controller_name: String)
signal controller_disconnected(device_id: int)

var connected_controllers: Dictionary = {}  # device_id -> nome

# Mapeamentos SDL para controles conhecidos que não estão na base padrão do Godot.
# Formato SDL: GUID,Nome,a:bX,...,platform:Windows,
const CUSTOM_MAPPINGS := [
	# ROG Ally RC71L — modo Gamepad (driver ASUS nativo)
	"03000000110100001914000000000000,ROG Ally RC71L,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b10,start:b7,leftstick:b8,rightstick:b9,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:a4,righttrigger:a5,platform:Windows,",
	# ROG Ally X e variantes
	"030000000b0500001abe000000010000,ROG Ally,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b10,start:b7,leftstick:b8,rightstick:b9,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:a4,righttrigger:a5,platform:Windows,",
	# ROG Ally modo alternativo
	"03000000110100003914000000000000,ROG Ally,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b10,start:b7,leftstick:b8,rightstick:b9,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:a4,righttrigger:a5,platform:Windows,",
]

func _ready() -> void:
	_apply_custom_mappings()
	_add_keyboard_fallbacks()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_scan_connected_controllers()

func _apply_custom_mappings() -> void:
	for mapping in CUSTOM_MAPPINGS:
		Input.add_joy_mapping(mapping, true)

# Adiciona as SETAS do teclado como alternativa de movimento e Enter para usar
# ferramenta. Muitos handhelds (ROG Ally em modo Desktop) mapeiam o D-pad para
# as setas — assim o jogo responde mesmo sem ser visto como "gamepad".
func _add_keyboard_fallbacks() -> void:
	_add_key_to_action("up", KEY_UP)
	_add_key_to_action("down", KEY_DOWN)
	_add_key_to_action("left", KEY_LEFT)
	_add_key_to_action("right", KEY_RIGHT)
	_add_key_to_action("use_tool", KEY_ENTER)
	_add_key_to_action("use_tool", KEY_KP_ENTER)

func _add_key_to_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		return
	# Evita duplicar se já existir um evento com essa tecla física
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and ev.physical_keycode == keycode:
			return
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _scan_connected_controllers() -> void:
	for device_id in Input.get_connected_joypads():
		var name := Input.get_joy_name(device_id)
		connected_controllers[device_id] = name
		print("[InputManager] Controle encontrado: %s (device %d)" % [name, device_id])

func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		var name := Input.get_joy_name(device_id)
		connected_controllers[device_id] = name
		print("[InputManager] Controle conectado: %s (device %d)" % [name, device_id])
		controller_connected.emit(device_id, name)
	else:
		var name: String = connected_controllers.get(device_id, "Desconhecido")
		connected_controllers.erase(device_id)
		print("[InputManager] Controle desconectado: %s (device %d)" % [name, device_id])
		controller_disconnected.emit(device_id)

func has_controller() -> bool:
	return connected_controllers.size() > 0

func get_controller_name(device_id: int = 0) -> String:
	return connected_controllers.get(device_id, "")
