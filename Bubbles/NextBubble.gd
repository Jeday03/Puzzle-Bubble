extends Node2D  # Este script gerencia a lógica para preparar e atualizar a próxima bolha a ser disparada

# Variável que armazena o número de tipos de bolhas disponíveis
# Ao ser modificada, chama a função 'prepare_first_bubble' para ajustar a bolha inicial
var number_of_available_bubble_types = 4 setget prepare_first_bubble

# Sinal emitido para notificar qual será o próximo tipo de bolha a ser disparada
signal next_bubble

# Variável que armazena o tipo atual da bolha na posição "on deck"
var type = 0


func _ready():
	# Define a textura dos nós 'BubbleOnDeck' e 'ReadyBubble' usando os sprites configurados em GameState
	$BubbleOnDeck.texture = GameState.bubble_sprites
	$ReadyBubble.texture = GameState.bubble_sprites


# Função setter chamada quando 'number_of_available_bubble_types' é modificada
func prepare_first_bubble(number_of_types):
	# Define o frame do nó 'ReadyBubble' para um valor aleatório entre 0 e number_of_types - 1
	$ReadyBubble.frame = randi() % number_of_types
	# Torna o nó 'ReadyBubble' invisível (pode ser usado apenas para armazenamento de dados)
	$ReadyBubble.visible = false
	# Define o frame do nó 'BubbleOnDeck' para o mesmo valor do 'ReadyBubble'
	$BubbleOnDeck.frame = $ReadyBubble.frame
	# Atualiza a variável 'type' com um novo valor aleatório, representando o próximo tipo de bolha
	type = randi() % number_of_types
	# Emite o sinal 'next_bubble' passando o frame atual de 'ReadyBubble'
	emit_signal("next_bubble", $ReadyBubble.frame)
	# Inicia a animação "BubbleOnDeck" para indicar visualmente a preparação da próxima bolha
	$AnimationPlayer.play("BubbleOnDeck")


# Função callback chamada pelo Level para preparar a bolha com base nos tipos disponíveis
func _on_Level_prepare_bubble(available_bubbles:Array):
	# Se não houver bolhas disponíveis, encerra a função
	if available_bubbles.size() == 0:
		return
	# Seleciona aleatoriamente um tipo dentre os disponíveis
	type = available_bubbles[randi() % available_bubbles.size()]
	# Define o frame do 'ReadyBubble' igual ao frame atual de 'BubbleOnDeck'
	$ReadyBubble.frame = $BubbleOnDeck.frame
	# Emite o sinal 'next_bubble' com o frame atual de 'ReadyBubble'
	emit_signal("next_bubble", $ReadyBubble.frame)
	# Reproduz a animação "BubbleOnDeck" para atualizar visualmente a bolha no deck
	$AnimationPlayer.play("BubbleOnDeck")


# Atualiza a textura dos nós para os novos símbolos (sprites) informados
func update_symbols(sprite):
	$BubbleOnDeck.texture = sprite
	$ReadyBubble.texture = sprite


# Restaura a cor/índice da bolha "on deck" para o valor armazenado na variável 'type'
func reset_on_deck_colour():
	$BubbleOnDeck.frame = type
