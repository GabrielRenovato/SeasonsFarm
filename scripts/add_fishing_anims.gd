extends SceneTree
## Rode via linha de comando (headless):
##   Godot.exe --headless --path <projeto> --script res://scripts/add_fishing_anims.gd

const FISHING_LIB_PATH := "res://systems/fishing/fishing_animations.tres"
const PLAYER_SCENE_PATH := "res://entities/player/player.tscn"

const DIRECTIONS := [
	["up",    Vector2( 0, -1)],
	["down",  Vector2( 0,  1)],
	["left",  Vector2(-1,  0)],
	["right", Vector2( 1,  0)],
]

const TRANSITIONS := [
	["FishCast",  "FishWait"],
	["FishWait",  "FishBite"],
	["FishWait",  "Idle"],
	["FishBite",  "FishReel"],
	["FishBite",  "Idle"],
	["FishReel",  "FishCatch"],
	["FishReel",  "Idle"],
	["FishCatch", "Idle"],
]

func _init() -> void:
	print("\n=== Baking fishing animations into player.tscn ===\n")

	var lib_res: AnimationLibrary = load(FISHING_LIB_PATH)
	if not lib_res:
		print("ERRO: nao encontrou " + FISHING_LIB_PATH)
		quit(1)
		return

	var packed: PackedScene = load(PLAYER_SCENE_PATH)
	if not packed:
		print("ERRO: nao encontrou " + PLAYER_SCENE_PATH)
		quit(1)
		return

	var player: Node = packed.instantiate()
	var anim_player: AnimationPlayer = player.get_node_or_null("AnimationPlayer")
	var anim_tree: AnimationTree   = player.get_node_or_null("AnimationTree")

	if not anim_player or not anim_tree:
		print("ERRO: AnimationPlayer ou AnimationTree nao encontrado em player.tscn")
		player.free()
		quit(1)
		return

	# ── Animacoes ──────────────────────────────────────────────────────────────
	var lib: AnimationLibrary = anim_player.get_animation_library("")
	if not lib:
		print("ERRO: biblioteca de animacoes padrao nao encontrada")
		player.free()
		quit(1)
		return

	for anim_name in lib_res.get_animation_list():
		if lib.has_animation(anim_name):
			lib.remove_animation(anim_name)
		var anim: Animation = lib_res.get_animation(anim_name).duplicate()
		var n: String = anim_name
		anim.loop_mode = Animation.LOOP_LINEAR if ("wait" in n or "bite" in n or "reel" in n) else Animation.LOOP_NONE
		lib.add_animation(anim_name, anim)
		print("  + animacao: ", n)

	# ── Nos do state machine ───────────────────────────────────────────────────
	var root: AnimationNodeStateMachine = anim_tree.tree_root as AnimationNodeStateMachine
	if not root:
		print("ERRO: AnimationTree.tree_root nao e um AnimationNodeStateMachine")
		player.free()
		quit(1)
		return

	for state in ["Wait", "Bite", "Reel", "Catch"]:
		var state_name: String = "Fish" + state
		if root.has_node(state_name):
			root.remove_node(state_name)
		var blend_space: AnimationNodeBlendSpace2D = AnimationNodeBlendSpace2D.new()
		for dir_data in DIRECTIONS:
			var anim_node: AnimationNodeAnimation = AnimationNodeAnimation.new()
			anim_node.animation = "fish_" + (state as String).to_lower() + "_" + (dir_data[0] as String)
			blend_space.add_blend_point(anim_node, dir_data[1] as Vector2)
		root.add_node(state_name, blend_space)
		print("  + estado SM: ", state_name)

	# ── Transicoes ─────────────────────────────────────────────────────────────
	for pair in TRANSITIONS:
		var from: String = pair[0]
		var to: String   = pair[1]
		if not root.has_node(from) or not root.has_node(to):
			print("  SKIP transicao ", from, " -> ", to, " (no ausente)")
			continue
		if root.has_transition(from, to):
			root.remove_transition(from, to)
		root.add_transition(from, to, AnimationNodeStateMachineTransition.new())
		print("  + transicao: ", from, " -> ", to)

	# ── Salva ──────────────────────────────────────────────────────────────────
	var new_packed := PackedScene.new()
	var err := new_packed.pack(player)
	if err != OK:
		print("ERRO ao empacotar a cena: ", err)
		player.free()
		quit(1)
		return

	err = ResourceSaver.save(new_packed, PLAYER_SCENE_PATH)
	if err != OK:
		print("ERRO ao salvar player.tscn: ", err)
		quit(1)
	else:
		print("\nSUCESSO: player.tscn salvo com animacoes de pesca embutidas.")

	player.free()
	quit()
