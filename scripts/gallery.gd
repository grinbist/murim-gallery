extends Node2D

# First vertical slice: Gallery -> painting -> combat -> loot/death -> saved comprehension.

const PLAYER_SPEED := 280.0
const ATTACK_RANGE := 110.0
const TECHNIQUE_COOLDOWN := 0.8

var state := "gallery"
var comprehension := 0
var health := 100.0
var qi := 60.0
var player_position := Vector2(260, 420)
var enemy_position := Vector2(980, 420)
var enemy_health := 100.0
var cooldown := 0.0
var message := "Нажми E у картины, чтобы войти"
var defeated := false
var loot_taken := false

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if state == "combat":
		_process_combat(delta)
	queue_redraw()

func _process_combat(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	player_position.x = clampf(player_position.x + direction * PLAYER_SPEED * delta, 100.0, 1180.0)
	if not defeated and enemy_health > 0.0:
		if player_position.distance_to(enemy_position) < 150.0:
			health = maxf(0.0, health - 8.0 * delta)
			if health <= 0.0:
				_return_to_gallery(false)
		if Input.is_action_just_pressed("technique_one"):
			_use_technique(25.0, 10.0, "Прямой удар")
		if Input.is_action_just_pressed("technique_two"):
			_use_technique(40.0, 25.0, "Разрыв меридиана")
	elif enemy_health <= 0.0 and not loot_taken:
		message = "Враг повержен. Нажми E, чтобы забрать фрагмент"
		if Input.is_action_just_pressed("interact"):
			loot_taken = true
			comprehension += 1
			message = "Фрагмент осмыслен: Постижение +1. Нажми E для выхода"
	elif loot_taken and Input.is_action_just_pressed("interact"):
		_return_to_gallery(true)

func _use_technique(damage: float, cost: float, technique_name: String) -> void:
	if cooldown > 0.0:
		return
	if qi < cost:
		message = "Недостаточно Ци"
		return
	if player_position.distance_to(enemy_position) > ATTACK_RANGE:
		message = "Подойди ближе к врагу"
		return
	qi -= cost
	enemy_health = maxf(0.0, enemy_health - damage)
	cooldown = TECHNIQUE_COOLDOWN
	message = technique_name + "! Урон: " + str(int(damage))
	if enemy_health <= 0.0:
		message = "Победа. Нажми E, чтобы забрать фрагмент"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and state == "gallery":
		state = "combat"
		health = 100.0
		qi = 60.0
		enemy_health = 100.0
		player_position = Vector2(260, 420)
		enemy_position = Vector2(980, 420)
		defeated = false
		loot_taken = false
		message = "Победи хранителя. A/D или стрелки — движение; 1/2 — техники"

func _return_to_gallery(victory: bool) -> void:
	state = "gallery"
	message = "Постижение сохранено: " + str(comprehension) + ". Нажми E у картины для нового входа"
	if not victory:
		message = "Ты пал. Постижение сохранено: " + str(comprehension) + ". Нажми E для возврата"

func _draw() -> void:
	if state == "gallery":
		_draw_gallery()
	else:
		_draw_combat()

func _draw_gallery() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("101522"))
	draw_rect(Rect2(90, 85, 1100, 550), Color("1e2940"), true)
	draw_rect(Rect2(420, 150, 440, 330), Color("c89146"), true)
	draw_rect(Rect2(445, 175, 390, 280), Color("263b52"), true)
	draw_circle(Vector2(640, 315), 70, Color("6f8f9b"))
	draw_line(Vector2(580, 370), Vector2(640, 265), Color("d7b56d"), 12.0)
	draw_string(ThemeDB.fallback_font, Vector2(450, 535), "ГАЛЕРЕЯ • КАРТИНА ПУТИ", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("ead8ad"))
	draw_string(ThemeDB.fallback_font, Vector2(110, 120), "MURIM GALLERY", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("f0c674"))
	draw_string(ThemeDB.fallback_font, Vector2(110, 590), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("d8e2ef"))
	draw_string(ThemeDB.fallback_font, Vector2(930, 120), "Постижение: " + str(comprehension), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("a9d6a5"))

func _draw_combat() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("17131f"))
	draw_rect(Rect2(50, 100, 1180, 500), Color("302b46"), true)
	draw_line(Vector2(70, 520), Vector2(1210, 520), Color("95724e"), 6.0)
	draw_circle(player_position, 34, Color("63a3d8"))
	draw_circle(enemy_position, 42, Color("c75c62"))
	draw_rect(Rect2(80, 40, 300, 22), Color("432b35"), true)
	draw_rect(Rect2(80, 40, 300 * health / 100.0, 22), Color("70c27b"), true)
	draw_rect(Rect2(80, 70, 300, 14), Color("233c5d"), true)
	draw_rect(Rect2(80, 70, 300 * qi / 60.0, 14), Color("55a6d8"), true)
	draw_rect(Rect2(900, 40, 300, 22), Color("432b35"), true)
	draw_rect(Rect2(900, 40, 300 * enemy_health / 100.0, 22), Color("d06a6a"), true)
	draw_string(ThemeDB.fallback_font, Vector2(80, 650), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("e6d6b7"))
	draw_string(ThemeDB.fallback_font, Vector2(80, 680), "HP  " + str(int(health)) + "     Ци  " + str(int(qi)) + "     [1] Прямой удар  [2] Разрыв меридиана", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("b9c7dc"))
	draw_string(ThemeDB.fallback_font, Vector2(900, 680), "Враг: " + str(int(enemy_health)), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f0b2a8"))
