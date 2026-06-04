"""
Adiciona as animações de pesca (Wait, Bite, Reel, Catch) ao player.tscn
no mesmo padrão das outras animações — direto no arquivo, sem instanciar cena.
"""

player_path = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\entities\player\player.tscn"

with open(player_path, "r", encoding="utf-8") as f:
    content = f.read()

# ── 1. ext_resource de texturas ──────────────────────────────────────────────

ext_resources = (
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.2. Fishing - Bite/Skins/1.png" id="fish_bite_skin"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.2. Fishing - Bite/Eyes/Male/Black.png" id="fish_bite_eyes"]\n'
    "[ext_resource type=\"Texture2D\" path=\"res://assets/sprites/Character/PNG/12.2. Fishing - Bite/Hair's/Standard/Brown.png\" id=\"fish_bite_hair\"]\n"
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.2. Fishing - Bite/Clothers/Farm/Blue.png" id="fish_bite_cloth"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.2. Fishing - Bite/Weapons/1.png" id="fish_bite_tool"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.4. Fishing - Catch/Skins/1.png" id="fish_catch_skin"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.4. Fishing - Catch/Eyes/Male/Black.png" id="fish_catch_eyes"]\n'
    "[ext_resource type=\"Texture2D\" path=\"res://assets/sprites/Character/PNG/12.4. Fishing - Catch/Hair's/Standard/Brown.png\" id=\"fish_catch_hair\"]\n"
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.4. Fishing - Catch/Clothers/Farm/Blue.png" id="fish_catch_cloth"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.4. Fishing - Catch/Weapons/1.png" id="fish_catch_tool"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.3. Fishing - Reel/Skins/1.png" id="fish_reel_skin"]\n'
    "[ext_resource type=\"Texture2D\" path=\"res://assets/sprites/Character/PNG/12.3. Fishing - Reel/Hair's/Standard/Brown.png\" id=\"fish_reel_hair\"]\n"
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.3. Fishing - Reel/Clothers/Farm/Blue.png" id="fish_reel_cloth"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.3. Fishing - Reel/Weapons/1.png" id="fish_reel_tool"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.1. Fishing - Wait/Skins/1.png" id="fish_wait_skin"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.1. Fishing - Wait/Eyes/Male/Black.png" id="fish_wait_eyes"]\n'
    "[ext_resource type=\"Texture2D\" path=\"res://assets/sprites/Character/PNG/12.1. Fishing - Wait/Hair's/Standard/Brown.png\" id=\"fish_wait_hair\"]\n"
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.1. Fishing - Wait/Clothers/Farm/Blue.png" id="fish_wait_cloth"]\n'
    '[ext_resource type="Texture2D" path="res://assets/sprites/Character/PNG/12.1. Fishing - Wait/Weapons/1.png" id="fish_wait_tool"]\n'
    "\n"
)

content = content.replace(
    '\n[sub_resource type="RectangleShape2D"',
    "\n" + ext_resources + '[sub_resource type="RectangleShape2D"',
    1
)
print("1. ext_resources inseridos")

# ── 2. Blocos de animação ─────────────────────────────────────────────────────

STATES = {
    "bite":  {"skin":"fish_bite_skin","eyes":"fish_bite_eyes","hair":"fish_bite_hair","cloth":"fish_bite_cloth","tool":"fish_bite_tool","hf":28,"fpd":7,"length":0.56,"loop":1,"dir_off":{"down":0,"left":7,"right":14,"up":21},"times":[0,0.08,0.16,0.24,0.32,0.4,0.48]},
    "catch": {"skin":"fish_catch_skin","eyes":"fish_catch_eyes","hair":"fish_catch_hair","cloth":"fish_catch_cloth","tool":"fish_catch_tool","hf":16,"fpd":4,"length":0.48,"loop":None,"dir_off":{"down":0,"left":4,"right":8,"up":12},"times":[0,0.12,0.24,0.36]},
    "reel":  {"skin":"fish_reel_skin","eyes":None,"hair":"fish_reel_hair","cloth":"fish_reel_cloth","tool":"fish_reel_tool","hf":16,"fpd":4,"length":0.48,"loop":1,"dir_off":{"down":0,"left":4,"right":8,"up":12},"times":[0,0.12,0.24,0.36]},
    "wait":  {"skin":"fish_wait_skin","eyes":"fish_wait_eyes","hair":"fish_wait_hair","cloth":"fish_wait_cloth","tool":"fish_wait_tool","hf":16,"fpd":4,"length":0.48,"loop":1,"dir_off":{"down":0,"left":4,"right":8,"up":12},"times":[0,0.12,0.24,0.36]},
}

def pfa(arr):
    return "PackedFloat32Array(" + ", ".join(str(x) for x in arr) + ")"

def gen_anim(state, direction):
    d = STATES[state]
    anim_id   = f"Animation_fish_{state}_{direction}"
    anim_name = f"fish_{state}_{direction}"
    start     = d["dir_off"][direction]
    frames    = list(range(start, start + d["fpd"]))
    times     = d["times"]
    tr        = [1] * d["fpd"]

    loop_line = f"loop_mode = {d['loop']}\n" if d["loop"] is not None else ""
    eyes_val  = "null" if d["eyes"] is None else f'ExtResource("{d["eyes"]}")'

    times_s = pfa(times)
    tr_s    = pfa(tr)
    vals_s  = "[" + ", ".join(str(f) for f in frames) + "]"
    hf      = d["hf"]

    def track_tex(idx, node, val):
        return (
            f'tracks/{idx}/type = "value"\n'
            f'tracks/{idx}/imported = false\n'
            f'tracks/{idx}/enabled = true\n'
            f'tracks/{idx}/path = NodePath("{node}:texture")\n'
            f'tracks/{idx}/interp = 1\n'
            f'tracks/{idx}/loop_wrap = true\n'
            f'tracks/{idx}/keys = {{\n'
            f'"times": PackedFloat32Array(0),\n'
            f'"transitions": PackedFloat32Array(1),\n'
            f'"update": 1,\n'
            f'"values": [{val}]\n'
            f'}}\n'
        )

    def track_val(idx, node, prop, val):
        return (
            f'tracks/{idx}/type = "value"\n'
            f'tracks/{idx}/imported = false\n'
            f'tracks/{idx}/enabled = true\n'
            f'tracks/{idx}/path = NodePath("{node}:{prop}")\n'
            f'tracks/{idx}/interp = 1\n'
            f'tracks/{idx}/loop_wrap = true\n'
            f'tracks/{idx}/keys = {{\n'
            f'"times": PackedFloat32Array(0),\n'
            f'"transitions": PackedFloat32Array(1),\n'
            f'"update": 1,\n'
            f'"values": [{val}]\n'
            f'}}\n'
        )

    def track_frames(idx, node):
        return (
            f'tracks/{idx}/type = "value"\n'
            f'tracks/{idx}/imported = false\n'
            f'tracks/{idx}/enabled = true\n'
            f'tracks/{idx}/path = NodePath("{node}:frame")\n'
            f'tracks/{idx}/interp = 1\n'
            f'tracks/{idx}/loop_wrap = true\n'
            f'tracks/{idx}/keys = {{\n'
            f'"times": {times_s},\n'
            f'"transitions": {tr_s},\n'
            f'"update": 1,\n'
            f'"values": {vals_s}\n'
            f'}}\n'
        )

    block  = f'[sub_resource type="Animation" id="{anim_id}"]\n'
    block += f'resource_name = "{anim_name}"\n'
    block += f'length = {d["length"]}\n'
    block += loop_line
    block += track_tex(0, "Body",    f'ExtResource("{d["skin"]}")')
    block += track_tex(1, "Eyes",    eyes_val)
    block += track_tex(2, "Hair",    f'ExtResource("{d["hair"]}")')
    block += track_tex(3, "Clothes", f'ExtResource("{d["cloth"]}")')
    block += track_tex(4, "Tool",    f'ExtResource("{d["tool"]}")')
    block += track_val(5, "Tool",    "visible", "true")
    for idx, node in enumerate(["Body","Eyes","Hair","Clothes","Tool"], 6):
        block += track_val(idx, node, "hframes", hf)
    for idx, node in enumerate(["Body","Eyes","Hair","Clothes","Tool"], 11):
        block += track_val(idx, node, "vframes", 1)
    for idx, node in enumerate(["Body","Eyes","Hair","Clothes","Tool"], 16):
        block += track_frames(idx, node)
    block += "\n"
    return block

all_anims = ""
for state in ["bite", "catch", "reel", "wait"]:
    for d in ["down", "left", "right", "up"]:
        all_anims += gen_anim(state, d)

content = content.replace(
    '[sub_resource type="AnimationLibrary" id="AnimationLibrary_new"]',
    all_anims + '[sub_resource type="AnimationLibrary" id="AnimationLibrary_new"]',
    1
)
print("2. Animações inseridas")

# ── 3. AnimationLibrary_new: registrar as 16 animações ───────────────────────

new_entries = ""
for state in ["bite", "catch", "reel", "wait"]:
    for d in ["down", "left", "right", "up"]:
        new_entries += f'&"fish_{state}_{d}": SubResource("Animation_fish_{state}_{d}"),\n'

content = content.replace(
    '&"fish_cast_down": SubResource("Animation_fish_cast_down"),',
    new_entries + '&"fish_cast_down": SubResource("Animation_fish_cast_down"),',
    1
)
print("3. AnimationLibrary_new atualizado")

# ── 4. AnimationNodeAnimation + BlendSpace2D ─────────────────────────────────

sm_nodes = ""
for state in ["bite", "catch", "reel", "wait"]:
    sc = state.capitalize()
    for d in ["up", "down", "left", "right"]:
        sm_nodes += (
            f'[sub_resource type="AnimationNodeAnimation" id="AnimationNodeAnimation_fish_{state}_{d}"]\n'
            f'animation = &"fish_{state}_{d}"\n\n'
        )
    sm_nodes += (
        f'[sub_resource type="AnimationNodeBlendSpace2D" id="AnimationNodeBlendSpace2D_Fish{sc}"]\n'
        f'blend_point_0/node = SubResource("AnimationNodeAnimation_fish_{state}_up")\n'
        f'blend_point_0/pos = Vector2(0, -1)\n'
        f'blend_point_1/node = SubResource("AnimationNodeAnimation_fish_{state}_down")\n'
        f'blend_point_1/pos = Vector2(0, 1)\n'
        f'blend_point_2/node = SubResource("AnimationNodeAnimation_fish_{state}_left")\n'
        f'blend_point_2/pos = Vector2(-1, 0)\n'
        f'blend_point_3/node = SubResource("AnimationNodeAnimation_fish_{state}_right")\n'
        f'blend_point_3/pos = Vector2(1, 0)\n'
        f'blend_mode = 1\n\n'
    )

# ── 5. Transições ─────────────────────────────────────────────────────────────

TRANSITIONS = [
    ("FishCast","FishWait"), ("FishWait","FishBite"), ("FishWait","Idle"),
    ("FishBite","FishReel"), ("FishBite","Idle"),
    ("FishReel","FishCatch"), ("FishReel","Idle"), ("FishCatch","Idle"),
]

trans_resources = ""
for (frm, to) in TRANSITIONS:
    tid = f"AnimationNodeStateMachineTransition_{frm}_{to}"
    trans_resources += f'[sub_resource type="AnimationNodeStateMachineTransition" id="{tid}"]\n\n'

content = content.replace(
    '[sub_resource type="AnimationNodeStateMachineTransition" id="AnimationNodeStateMachineTransition_start"]',
    sm_nodes + trans_resources + '[sub_resource type="AnimationNodeStateMachineTransition" id="AnimationNodeStateMachineTransition_start"]',
    1
)
print("4. AnimationNodeAnimation + BlendSpace2D + Transições inseridos")

# ── 6. AnimationNodeStateMachine_Root: estados e transições ──────────────────

positions = {
    "FishBite":  "Vector2(600, 100)",
    "FishCatch": "Vector2(600, 200)",
    "FishReel":  "Vector2(600, 300)",
    "FishWait":  "Vector2(600, 400)",
}

new_states = ""
for state in ["bite", "catch", "reel", "wait"]:
    sc = state.capitalize()
    new_states += (
        f'states/Fish{sc}/node = SubResource("AnimationNodeBlendSpace2D_Fish{sc}")\n'
        f'states/Fish{sc}/position = {positions["Fish"+sc]}\n'
    )

content = content.replace(
    'states/FishCast/position = Vector2(400, 200)\n',
    'states/FishCast/position = Vector2(400, 200)\n' + new_states,
    1
)

new_trans_entries = ""
for (frm, to) in TRANSITIONS:
    tid = f"AnimationNodeStateMachineTransition_{frm}_{to}"
    new_trans_entries += f', "{frm}", "{to}", SubResource("{tid}")'

content = content.replace(
    'transitions = ["Start", "Idle", SubResource("AnimationNodeStateMachineTransition_start")]',
    f'transitions = ["Start", "Idle", SubResource("AnimationNodeStateMachineTransition_start"){new_trans_entries}]',
    1
)
print("5. AnimationNodeStateMachine_Root atualizado")

# ── 7. AnimationTree: parâmetros de blend_position ───────────────────────────

new_params = ""
for state in ["bite", "catch", "reel", "wait"]:
    sc = state.capitalize()
    new_params += f'parameters/Fish{sc}/blend_position = Vector2(0, 0)\n'

content = content.replace(
    'parameters/FishCast/blend_position = Vector2(0, 0)\n',
    'parameters/FishCast/blend_position = Vector2(0, 0)\n' + new_params,
    1
)
print("6. AnimationTree parâmetros atualizados")

# ── Salva ─────────────────────────────────────────────────────────────────────

with open(player_path, "w", encoding="utf-8") as f:
    f.write(content)

print("\nSUCESSO: player.tscn atualizado!")
