extends TileMap  # Este script gerencia o conjunto de tiles (tileset) que serão usados para as bolhas no jogo

# Pré-carrega os recursos de tilesets:
# - 'blank_bubbles' é o conjunto de tiles sem símbolos
# - 'symbol_bubbles' é o conjunto de tiles com símbolos
var blank_bubbles = preload("res://Bubbles/Blank_bubbles.tres")
var symbol_bubbles = preload("res://Bubbles/Symbol_bubbles.tres")

func _ready():
	# Quando o TileMap é inicializado, verifica qual tileset deve ser usado
	check_tileset()

# Função que seleciona o tileset com base no modo de símbolos definido em GameState
func check_tileset():
	if GameState.symbols_mode:
		# Se o modo de símbolos estiver ativado, usa o conjunto de tiles com símbolos
		tile_set = symbol_bubbles
	else:
		# Caso contrário, usa o conjunto de tiles sem símbolos
		tile_set = blank_bubbles

# Função que atualiza os símbolos exibidos (pode ser chamada por outros nós para refletir mudanças)
func update_symbols(_symbols):
	# Apenas verifica novamente o tileset para atualizar a aparência das bolhas conforme a configuração atual
	check_tileset()
