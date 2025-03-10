extends Node2D  # Define que este script é um nó 2D, possibilitando manipulação de posição, rotação, etc.

# Pré-carrega a cena da bolha para que possa ser instanciada posteriormente
var Bubble = preload("res://Bubbles/Bubble.tscn")
# Variável que armazena o tipo da próxima bolha a ser criada
var next_bubble_type = 0

# Constante que define a velocidade do impulso aplicado à bolha
const SPEED = 500

# Função que é chamada quando o nível solicita a criação de uma nova bolha
func _on_Level_spawn_bubble(angle, location):
	# Toca o efeito sonoro associado à criação da bolha
	$BubbleSFXPlayer.play()
	# Cria uma nova instância da cena Bubble
	var new_Bubble = Bubble.instance()
	# Define o tipo da nova bolha com base no valor armazenado em next_bubble_type
	new_Bubble.type = next_bubble_type
	# Posiciona a nova bolha na posição global informada
	new_Bubble.global_position = location
	# Adiciona a nova bolha como filho deste nó, inserindo-a na cena
	add_child(new_Bubble)
	# Aplica um impulso central à nova bolha:
	# Cria um vetor apontando para cima (-Vector2(0,1)), rotacionado pelo ângulo fornecido, multiplicado pela constante SPEED.
	new_Bubble.apply_central_impulse(-Vector2(0,1).rotated(angle) * SPEED)
	# Conecta o sinal "bubble_stopped" da nova bolha ao método "bubble_stopped" do nó pai deste nó
	new_Bubble.connect("bubble_stopped", get_parent(), "bubble_stopped")

# Função que é chamada para atualizar o tipo da próxima bolha a ser instanciada
func _on_NextBubble_next_bubble(type):
	# Atualiza a variável next_bubble_type com o novo tipo recebido
	next_bubble_type = type
