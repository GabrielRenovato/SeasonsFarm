extends Area2D

# Cena da cidade carregada antecipadamente para transição instantânea
const CITY_SCENE: PackedScene = preload("res://levels/city/city.tscn")
const FARM_SCENE_PATH: String = "res://levels/main_farm/farm.tscn"

# Controla se a transição já começou para não acontecer múltiplas vezes seguidas
var _is_exiting: bool = false

func _ready() -> void:
    # Quando o corpo entrar na área, disparar a função
    body_entered.connect(_on_body_entered)

# Função chamada quando o jogador entra na área (quando ele pisar na borda)
func _on_body_entered(body: Node2D) -> void:
    if _is_exiting:
        return
    # Verificar se quem pisou na transição foi mesmo o Player
    if body is CharacterBody2D:
        _is_exiting = true
        
        # Salva a posição do player (um pouco para baixo para não engatilhar o portal ao voltar)
        var safe_pos = body.global_position + Vector2(0, 32)
        SaveManager.set_pending_spawn(FARM_SCENE_PATH, safe_pos)
        SaveManager.save_game()
        
        # Fazemos a troca de cena para a cidade mantendo a fazenda guardada
        SaveManager.call_deferred("enter_stashed_scene", CITY_SCENE)
