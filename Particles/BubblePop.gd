extends Particles2D  # Estende a classe Particles2D para criar efeitos de partículas, como bolhas

# Exporta a variável 'pops' para o editor, que é um Array de Resources (provavelmente sons de estouro)
export (Array, Resource) var pops

# Variável 'type' que armazena um inteiro e utiliza o setter 'change_colour' para alterar propriedades visuais
var type = 0 setget change_colour

func _ready():
	# Função _ready: executada quando o nó entra na cena
	# Define a textura das partículas utilizando os sprites de bolhas armazenados em GameState
	texture = GameState.bubble_sprites

func change_colour(value):
	# Setter que altera a cor ou aparência das partículas
	# Ajusta o deslocamento da animação no material processador, modificando a aparência das partículas
	process_material.anim_offset = value * 0.1

func pop_bubbles():
	# Função que simula o estouro das bolhas
	# Seleciona aleatoriamente um som de estouro a partir do array 'pops'
	$BubblePopSFX.stream = pops[randi() % pops.size()]
	# Toca o som de estouro selecionado
	$BubblePopSFX.play()
	# Executa a animação "Pop" através do AnimationPlayer para mostrar visualmente o estouro
	$AnimationPlayer.play("Pop")
