extends Node2D  # Este script gerencia a lógica principal do jogo, incluindo o posicionamento das bolhas, detecção de combinações e verificação de condições de fim de jogo

# Referência ao TileMap (nomeado aqui como Hex) presente na cena
onready var Hex = $TileMap

# Sinais que serão emitidos para comunicar eventos importantes durante o jogo:
signal spawn_bubble      # Sinal para solicitar o disparo de uma nova bolha
signal prepare_bubble    # Sinal para preparar a próxima bolha com base nas bolhas restantes
signal can_fire          # Sinal indicando que o jogador pode disparar uma nova bolha
signal game_over         # Sinal para indicar que o jogo acabou
signal panic             # Sinal para notificar situação crítica (quando as bolhas se aproximam do limite inferior)

# Variáveis para armazenar dados do jogo
var PlayerLoc: Vector2            # Armazena a posição do jogador
var matching_bubbles = []         # Lista de bolhas que combinam (mesmo tipo) para remoção
var bubbles_checked = []          # Lista de bolhas já verificadas ao procurar correspondências
var spawn_counter = 0             # Contador de bolhas disparadas (usado para mover o teto periodicamente)

var bubbles_to_score = 0          # Acumula os pontos a serem somados ao score

# Constantes que definem as dimensões do mapa e parâmetros de jogo
const MAP_X = 19                # Número de células no eixo X
const MAP_Y = 13                # Número de células no eixo Y
const CELL_TYPE = 1             # Índice usado para acessar o tipo de célula (bolha)
const SPAWN_LIMIT = 10          # Limite de bolhas disparadas antes de mover o teto

# Variável exportada para configurar o número de tipos de bolhas disponíveis (entre 2 e 10)
export (int, 2, 10) var number_of_bubble_types = 4

# Pré-carrega as cenas dos efeitos de partículas para o estouro e a queda de bolhas
var bubble_pop_particle = preload("res://Particles/BubblePop.tscn")
var bubble_drop_particle = preload("res://Particles/BubbleDrop.tscn")

# Função _ready: chamada quando o nó entra na cena
func _ready():
	# Define o número de tipos de bolhas de acordo com a dificuldade definida no GameState
	number_of_bubble_types = GameState.difficulty
	# Inicializa a semente para números aleatórios
	randomize()
	# Preenche a metade superior do TileMap com bolhas de tipos aleatórios
	for x in range(1, MAP_X):
		for y in floor(MAP_Y/2):
			var bubble_type = randi() % number_of_bubble_types
			Hex.set_cell(x, y, bubble_type)
	# Atualiza a posição do jogador
	PlayerLoc = get_PlayerLoc()
	# Define no nó NextBubble o número de tipos de bolhas disponíveis para a próxima bolha a ser disparada
	$NextBubble.number_of_available_bubble_types = number_of_bubble_types

# Retorna a posição global do jogador
func get_PlayerLoc():
	return $Player.global_position

# Callback chamado quando o jogador dispara uma bolha
func _on_Player_fire_bubble(angle):
	# Emite o sinal para criar uma nova bolha, passando o ângulo e a posição do jogador
	emit_signal("spawn_bubble", angle, PlayerLoc)
	# Verifica quais tipos de bolhas estão presentes no TileMap para preparar a próxima bolha
	check_remaining_bubbles()

# Verifica os tipos de bolhas restantes no TileMap para informar a preparação da próxima bolha
func check_remaining_bubbles():
	var bubbles = []
	# Obtém todas as células atualmente usadas no TileMap
	var cells = $TileMap.get_used_cells()
	# Para cada célula, armazena sua posição e o tipo de bolha contido nela
	for cell in cells:
		bubbles.append([cell, $TileMap.get_cellv(cell)])
	var available_bubbles = []
	# Cria uma lista com os tipos únicos de bolhas existentes
	for bubble in bubbles:
		if not available_bubbles.has(bubble[CELL_TYPE]):
			available_bubbles.append(bubble[CELL_TYPE])
	# Emite o sinal para preparar a próxima bolha, passando os tipos disponíveis
	emit_signal("prepare_bubble", available_bubbles)

# Função chamada quando uma bolha disparada para (estoura ou trava)
func bubble_stopped(pos, bubble, type):
	# Converte a posição global da bolha para coordenadas locais e, em seguida, para coordenadas de célula do TileMap
	pos = $TileMap.to_local(pos)
	pos = $TileMap.world_to_map(pos)
	# Define a célula correspondente no TileMap com o tipo da bolha
	$TileMap.set_cell(pos.x, pos.y, type)
	# Remove a bolha da cena
	bubble.queue_free()
	
	# Verifica se o jogo chegou a um estado de término
	check_game_over()
	
	### Inicia a verificação de bolhas adjacentes (para possíveis combinações)
	matching_bubbles = [pos]  # Inicia a lista com a posição da bolha parada
	bubbles_checked = []      # Limpa a lista de bolhas já verificadas
	$Timer.start()            # Inicia um timer para gerenciar a sequência de verificação e pontuação
	check_neighbours(pos)     # Procura por bolhas vizinhas com o mesmo tipo
	spawn_counter += 1        # Incrementa o contador de bolhas disparadas

# Procura recursivamente por bolhas vizinhas com o mesmo tipo (para formar grupos que serão removidos)
func check_neighbours(cell):
	# Marca a célula atual como verificada
	bubbles_checked.append(cell)
	# Obtém os vizinhos da célula atual
	var neighbours = get_my_neighbours(cell)
	# Obtém todas as células usadas no TileMap
	var used_cells = $TileMap.get_used_cells()
	# Para cada vizinho
	for n in neighbours:
		# Se o vizinho ainda não foi verificado e está presente no TileMap
		if not bubbles_checked.has(cell+n) and used_cells.has(cell+n):
			# Se o tipo da bolha vizinha for igual ao da célula atual
			if $TileMap.get_cellv(cell+n) == $TileMap.get_cellv(cell):
				# Adiciona o vizinho à lista de bolhas que combinam
				matching_bubbles.append(cell+n)
				# Chama recursivamente para verificar os vizinhos deste vizinho
				check_neighbours(cell+n)

# Retorna os vizinhos de uma célula considerando o layout do TileMap (possivelmente hexagonal)
func get_my_neighbours(cell):
	# Lista de vizinhos para linhas pares
	var neighbours = [
			Vector2(-1,-1), Vector2(0,-1),
			Vector2(-1,0), Vector2(1,0),
			Vector2(-1,1), Vector2(0,1)
			]
	# Lista de vizinhos para linhas ímpares (offset)
	var offset_neighbours = [
			Vector2(0,-1), Vector2(1,-1),
			Vector2(-1,0), Vector2(1,0),
			Vector2(0,1), Vector2(1,1)
		]
	# Se a linha (y) da célula for ímpar, retorna os vizinhos com offset; caso contrário, retorna os vizinhos padrão
	if int(cell.y) % 2:
		return offset_neighbours
	else:
		return neighbours

# Callback do Timer: executado quando o Timer expira
func _on_Timer_timeout():
	# Verifica se há combinações de bolhas para pontuar
	check_bubble_counter()
	# Verifica se o limite de disparos foi atingido para mover o teto
	check_spawn_counter()
	# Permite que o jogador dispare novamente emitindo o sinal can_fire
	emit_signal("can_fire", true)
	# Atualiza a pontuação do jogador adicionando os pontos acumulados
	$CanvasLayer/Score.score += bubbles_to_score
	# Reseta a pontuação acumulada para a próxima rodada
	bubbles_to_score = 0
	# Verifica novamente as condições de término do jogo
	check_game_over()

# Verifica se o grupo de bolhas combinadas é grande o suficiente para pontuar e removê-las
func check_bubble_counter():
	# Se houver mais de 2 bolhas que combinam
	if matching_bubbles.size() > 2:
		# Calcula a pontuação: 3 pontos base + 2 pontos extras por bolha adicional além de 3
		bubbles_to_score += 3 + ((matching_bubbles.size() - 3) * 2)
		# Para cada bolha que combinou
		for bubble in matching_bubbles:
			# Instancia o efeito de estouro da bolha
			var pop = bubble_pop_particle.instance()
			add_child(pop)
			# Posiciona o efeito convertendo a posição da célula para coordenadas globais e ajustando para centralização
			pop.position = $TileMap.to_global($TileMap.map_to_world(bubble) + Vector2(16, 16))
			# Define o tipo do efeito com base na bolha
			pop.type = $TileMap.get_cellv(bubble)
			# Adiciona o efeito ao grupo "pop" para facilitar o controle em massa
			pop.add_to_group("pop")
			# Remove a bolha do TileMap, definindo sua célula como vazia (-1)
			$TileMap.set_cellv(bubble, -1)
		# Chama a função pop_bubbles em todos os nós do grupo "pop" para executar o efeito visual
		get_tree().call_group("pop", "pop_bubbles")
	# Após processar combinações, verifica bolhas destacadas e situações de pânico
	check_detatched_bubbles()
	check_panic()

# Verifica e remove as bolhas que se desprenderam (não conectadas ao topo do TileMap)
func check_detatched_bubbles():
	# Obtém todas as células atualmente usadas (ou seja, todas as bolhas)
	var detached_bubbles = $TileMap.get_used_cells()
	
	# Reinicia as listas de verificação
	bubbles_checked = []
	matching_bubbles = []
	
	### Marca as bolhas da linha superior como "conectadas"
	for bubble_number in detached_bubbles.size():
		if detached_bubbles[bubble_number].y == 0:
			matching_bubbles.append(detached_bubbles[bubble_number])
	
	### Verifica bolhas contíguas para identificar todas as conectadas ao topo
	for cell in detached_bubbles:
		bubbles_checked.append(cell)
		var neighbours = get_my_neighbours(cell)
		for n in neighbours:
			# Se a célula atual está marcada como conectada e o vizinho ainda não foi verificado
			if matching_bubbles.has(cell) and not bubbles_checked.has(cell+n):
				# Marca o vizinho como conectado
				matching_bubbles.append(cell+n)
				
	### Remove as bolhas que não estão conectadas ao topo (desprendidas)
	for bubble in detached_bubbles:
		if not matching_bubbles.has(bubble):
			# Instancia o efeito de queda da bolha
			var drop = bubble_drop_particle.instance()
			add_child(drop)
			# Posiciona o efeito convertendo a posição da célula para coordenadas globais
			drop.position = $TileMap.to_global($TileMap.map_to_world(bubble) + Vector2(16, 16))
			# Define o tipo do efeito conforme a bolha
			drop.type = $TileMap.get_cellv(bubble)
			# Remove a bolha do TileMap
			$TileMap.set_cellv(bubble, -1)
			# Adiciona pontos pela bolha desprendida
			bubbles_to_score += number_of_bubble_types * 2
	# Chama a função drop_bubbles em todos os nós do grupo "Drop" para executar o efeito visual de queda
	get_tree().call_group("Drop", "drop_bubbles")

# Verifica se o número de bolhas disparadas atingiu o limite para mover o teto
func check_spawn_counter():
	if spawn_counter == SPAWN_LIMIT:
		move_ceiling_down()

# Move o teto do jogo para baixo, aumentando a pressão sobre o jogador
func move_ceiling_down():
	# Cria uma interpolação (tween) para mover o TileMap 27 pixels para baixo com efeito elástico em 0.5 segundos
	$BubbleTween.interpolate_property($TileMap, "position",
			$TileMap.position, $TileMap.position + Vector2(0, 27),
			0.5,
			$BubbleTween.TRANS_ELASTIC,
			Tween.EASE_IN_OUT
			)
	$BubbleTween.start()
	# Cria uma interpolação para mover o teto ($Ceiling) 27 pixels para baixo com as mesmas configurações
	$CeilingTween.interpolate_property($Ceiling, "position",
			$Ceiling.position, $Ceiling.position + Vector2(0, 27),
			0.5,
			$CeilingTween.TRANS_ELASTIC,
			Tween.EASE_IN_OUT
			)
	$CeilingTween.start()
	# Reinicia o contador de bolhas disparadas
	spawn_counter = 0

# Função para finalizar o jogo
func game_over(has_won):
	# Se o nó do jogador existir, remove-o juntamente com o nó da próxima bolha
	if $Player:
		$Player.queue_free()
		$NextBubble.queue_free()
	# Exibe a tela de fim de jogo via MenuPopup, passando se o jogador venceu (has_won)
	$UILayer/MenuPopup.game_over(has_won)
	# Emite o sinal game_over para notificar outros nós
	emit_signal("game_over", has_won)

# Verifica se as condições de fim de jogo foram atingidas
func check_game_over():
	# Obtém todas as bolhas existentes no TileMap
	var bubbles = $TileMap.get_used_cells()

	# Se não houver nenhuma bolha, o jogador venceu
	if bubbles.size() == 0: 
		game_over(true)
		return
	
	# Define uma linha de "fim" convertendo a posição (0,350) para coordenadas do TileMap
	var finish_line = $TileMap.to_local(Vector2(0, 350))
	finish_line = $TileMap.world_to_map(finish_line)
	finish_line = finish_line.y
	
	# Se alguma bolha ultrapassar essa linha, o jogador perde
	for bubble in bubbles:
		if bubble.y >= finish_line:
			game_over(false)

# Callback chamado quando a animação do tween do TileMap é completada
func _on_BubbleTween_tween_all_completed():
	check_game_over()

# Processa entradas não tratadas; por exemplo, exibe o menu de pausa quando o jogador pressiona "cancelar"
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not $UILayer/MenuPopup.visible:
		$UILayer/MenuPopup.popup_centered()

# Verifica se alguma bolha atingiu uma linha crítica e emite um sinal de pânico se necessário
func check_panic():
	var should_panic = false
	# Obtém todas as bolhas existentes no TileMap
	var bubbles = $TileMap.get_used_cells()
	# Define a linha crítica (panic_line) convertendo a posição (0,323) para coordenadas do TileMap
	var panic_line = $TileMap.to_local(Vector2(0, 323))
	panic_line = $TileMap.world_to_map(panic_line)
	panic_line = panic_line.y
	
	# Se alguma bolha estiver abaixo da linha crítica, ativa o pânico
	for bubble in bubbles:
		if bubble.y >= panic_line:
			should_panic = true
	
	# Emite o sinal panic com o valor booleano resultante
	emit_signal("panic", should_panic)
