extends Particles2D  # Estende a classe Particles2D, permitindo a utilização de efeitos de partículas

# Função _ready: chamada quando o nó entra na cena, permitindo a inicialização dos parâmetros
func _ready():
	# Define a textura das partículas utilizando os sprites das bolhas armazenados no GameState
	texture = GameState.bubble_sprites

# Função update_symbols: atualiza dinamicamente a textura/símbolos das partículas
func update_symbols(bubbles):
	# Atualiza a textura das partículas com o novo conjunto de sprites recebido no parâmetro 'bubbles'
	texture = bubbles
