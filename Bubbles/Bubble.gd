extends RigidBody2D  # Define que este script estende a classe RigidBody2D, permitindo simulação física

# Variável 'type' que armazena um valor inteiro e utiliza a função 'change_colour' como setter
var type = 0 setget change_colour

# Sinal que será emitido quando a bolha parar (travar)
signal bubble_stopped

func _ready():
	# Ao iniciar, define a textura do Sprite com as sprites de bolha armazenadas no GameState
	$Sprite.texture = GameState.bubble_sprites

# Função setter para 'type' que também atualiza o frame do Sprite
func change_colour(number:int):
	# Atribui o novo valor à variável 'type'
	type = number
	# Atualiza o frame do Sprite para refletir a nova cor ou tipo
	$Sprite.frame = type

# Função de callback chamada quando outro corpo entra em contato com a bolha
func _on_Bubble_body_entered(body):
	# Verifica se o corpo colidido pertence a uma camada de colisão maior que 1
	if body.collision_layer > 1:
		# Se sim, trava a bolha chamando a função lock_bubble()
		lock_bubble()

# Função que trava a bolha e emite o sinal 'bubble_stopped'
func lock_bubble():
	# Emite o sinal 'bubble_stopped' enviando a posição atual, referência a si mesmo e o tipo da bolha
	emit_signal("bubble_stopped", position, self, type)

# Função executada a cada frame de física
func _physics_process(_delta):
	# Se a velocidade vertical (y) for positiva (movimento para baixo)
	if linear_velocity.y > 0:
		# Inverte a velocidade vertical para garantir que a bolha se mova para cima
		linear_velocity.y *= -1
