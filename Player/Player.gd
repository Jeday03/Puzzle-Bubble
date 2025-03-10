extends Node2D  # Este script gerencia a mira e o disparo da bolha

# Constantes que definem o ângulo máximo permitido para a mira e a velocidade de rotação
const MAX_ANGLE = 70
const ROTATION_SPEED = 1

# Sinal emitido para disparar a bolha, enviando o ângulo atual da mira
signal fire_bubble

# Variável que indica se o jogador pode disparar uma nova bolha
var can_fire = true

func _ready():
	# Inicializa a semente dos números aleatórios
	randomize()


func _process(_delta):
	# Calcula a rotação desejada com base na força das ações "Right" e "Left"
	var rot = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	# Se a nova rotação não ultrapassar o ângulo máximo permitido, atualiza a rotação do Aimer
	if abs($Aimer.rotation_degrees + rot * ROTATION_SPEED) <= MAX_ANGLE:
		$Aimer.rotation_degrees += rot * ROTATION_SPEED
	
	# Calcula a distância do ponto atual até o ponto de colisão dos dois RayCast2D filhos do Aimer
	var AimLine_distance_1 = position.distance_to($Aimer/RayCast2D.get_collision_point())
	var AimLine_distance_2 = position.distance_to($Aimer/RayCast2D2.get_collision_point())
	
	# Define o alvo da mira como a menor distância entre as duas
	var aim_target = min(AimLine_distance_1, AimLine_distance_2)
	# Atualiza o primeiro ponto da linha de mira (AimeLine) com base na distância e na rotação do Aimer
	$AimeLine.points[0] = Vector2(0, -aim_target).rotated($Aimer.rotation)


func _unhandled_input(event):
	# Verifica se a ação "Fire" foi pressionada e chama a função de disparo
	if event.is_action_pressed("Fire"):
		fire()
	# Permite ajustes finos à esquerda (Nudge_Left), garantindo que o ângulo não ultrapasse o limite
	if event.is_action_pressed("Nudge_Left"):
		if abs($Aimer.rotation_degrees - 1) <= MAX_ANGLE:
			$Aimer.rotation_degrees -= 1
	# Permite ajustes finos à direita (Nudge_Right), garantindo que o ângulo não ultrapasse o limite
	if event.is_action_pressed("Nudge_Right"):
		if abs($Aimer.rotation_degrees + 1) <= MAX_ANGLE:
			$Aimer.rotation_degrees += 1


func _on_Timer_timeout():
	# Reseta o frame do AnimatedSprite para 0
	$AnimatedSprite.frame = 0
	# Define uma lista de animações para dar variação visual à mira
	var animations = ["blink", "flap", "look"]
	# Toca uma animação aleatória da lista
	$AnimatedSprite.play(animations[randi() % animations.size()])


func _on_AnimatedSprite_animation_finished():
	# Se a animação finalizada não for "idle", retorna à animação ociosa
	if $AnimatedSprite.animation != "idle":
		$AnimatedSprite.play("idle")


func fire():
	# Verifica se o jogador pode disparar uma bolha
	if can_fire:
		# Emite o sinal 'fire_bubble' com o ângulo atual do Aimer
		emit_signal("fire_bubble", $Aimer.rotation)
		# Impede disparos adicionais até que a ação seja reabilitada
		can_fire = false
		# Oculta a linha de mira para indicar que o disparo foi efetuado
		$AimeLine.hide()


func set_fire(value):
	# Atualiza a variável de controle de disparo com o valor recebido
	can_fire = value
	# Exibe a linha de mira, permitindo ao jogador visualizar a direção para o próximo disparo
	$AimeLine.show()
