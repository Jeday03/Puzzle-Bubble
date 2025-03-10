extends Particles2D  # Estende a classe Particles2D para criar efeitos de partículas

# Variável 'type' que armazena um valor inteiro e utiliza a função 'change_colour' como setter.
# Isso permite que, ao alterar o valor, a função 'change_colour' seja chamada automaticamente.
var type = 0 setget change_colour

func _ready():
	# Função _ready é chamada quando o nó entra na cena.
	# Aqui, definimos a textura das partículas com os sprites das bolhas armazenados em GameState.
	texture = GameState.bubble_sprites

func drop_bubbles():
	# Chama a animação "Drop" no AnimationPlayer, que provavelmente anima a queda das bolhas.
	$AnimationPlayer.play("Drop")

func change_colour(value):
	# Função setter para alterar a cor (ou aparência) das partículas.
	# Ajusta o 'anim_offset' do material processador das partículas (process_material)
	# Multiplicando o valor por 0.1 para definir o deslocamento da animação.
	process_material.anim_offset = value * 0.1
