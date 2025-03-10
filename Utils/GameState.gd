extends Node  # Este nó principal gerencia as configurações do jogo

# Variáveis exportadas para o editor, com setters para executar funções sempre que seus valores são modificados
export (int) var difficulty = 4 setget set_difficulty         # Dificuldade do jogo
export (bool) var fullscreen = false setget set_fullscreen       # Define se o jogo está em tela cheia

# Volumes para música e efeitos sonoros, com valores entre -10 e 0
export (int, -10, 0) var music_volume = -3 setget set_music_volume
export (int, -10, 0) var sfx_volume = -3 setget set_sfx_volume

# Cria uma nova instância de ConfigFile para gerenciar o arquivo de configurações
var config = ConfigFile.new()
const CONFIG_FILE = "user://settings.cfg"  # Caminho do arquivo de configurações

# Variável que controla o modo de símbolos (se true, utiliza sprites com símbolos)
var symbols_mode :bool = true setget set_symbols_mode

# Pré-carrega os sprites das bolhas para os modos padrão e com símbolos
var blank_sprites = preload("res://Sprites/BubbleSpriteSheet.png")
var symbol_sprites = preload("res://Sprites/BubbleSpriteSheet2.png")

# Sprite atualmente em uso; inicia com os sprites de símbolos
var bubble_sprites = symbol_sprites

# Lista inicial de pontuações altas (highscores)
var highscores = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Configurações padrão caso o arquivo de configurações não exista
var default_settings = {
	"audio": {
		"music_volume": -3, 
		"sfx_volume": -3
	},
	"video": {
		"fullscreen": false, 
		"symbols": false
	},
	"game": {
		"difficulty": 4, 
		"highscores": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	}
}

# Estrutura que armazenará as configurações carregadas do arquivo
var settings = {
	"audio": {
		"music_volume": null, 
		"sfx_volume": null
	},
	"video": {
		"fullscreen": null, 
		"symbols": null
	},
	"game": {
		"difficulty": null, 
		"highscores": null
	}
}

# Função _ready: executada quando o nó entra na cena
func _ready():
	load_settings()  # Carrega as configurações do arquivo

	# Atualiza e aplica as configurações de áudio
	music_volume = settings["audio"]["music_volume"]
	set_music_volume(music_volume)
	sfx_volume = settings["audio"]["sfx_volume"]
	set_sfx_volume(sfx_volume)
	
	# Atualiza a lista de highscores e a ordena (ordem decrescente)
	highscores = settings["game"]["highscores"]
	highscores.sort_custom(self, "sort_scores")
	
	# Atualiza e aplica as configurações de vídeo
	fullscreen = settings["video"]["fullscreen"]
	set_fullscreen(fullscreen)
	symbols_mode = settings["video"]["symbols"]
	set_symbols_mode(symbols_mode)
	
	# Atualiza e aplica a dificuldade do jogo
	difficulty = settings["game"]["difficulty"]
	set_difficulty(difficulty)

# Função para ordenar as pontuações em ordem decrescente
func sort_scores(a, b):
	if a > b:
		return true
	else:
		return false

# Define e aplica a configuração de tela cheia
func set_fullscreen(is_fullscreen):
	fullscreen = is_fullscreen                          # Atualiza a variável local
	OS.window_fullscreen = is_fullscreen                # Configura a janela para tela cheia ou janela
	settings["video"]["fullscreen"] = fullscreen       # Atualiza a configuração no dicionário
	save_settings()                                    # Salva as configurações no arquivo

# Define e aplica o modo de símbolos para as bolhas
func set_symbols_mode(symbols):
	symbols_mode = symbols                             # Atualiza a variável local
	if symbols:
		bubble_sprites = symbol_sprites              # Se verdadeiro, usa sprites com símbolos
	else:
		bubble_sprites = blank_sprites               # Caso contrário, usa sprites padrão
	# Atualiza todos os nós do grupo "Bubbles" com a nova textura
	get_tree().call_group("Bubbles", "update_symbols", bubble_sprites)
	settings["video"]["symbols"] = symbols_mode        # Atualiza a configuração no dicionário
	save_settings()                                    # Salva as configurações

# Carrega as configurações do arquivo CONFIG_FILE
func load_settings():
	var error = config.load(CONFIG_FILE)              # Tenta carregar o arquivo de configurações
	if error != OK:
		make_default_config_file()                    # Se falhar, cria um arquivo padrão
	
	# Para cada seção e chave, obtém o valor armazenado, ou usa o padrão se não existir
	for section in settings.keys():
		for key in settings[section]:
			settings[section][key] = config.get_value(section, key, default_settings[section][key])
	
	save_settings()                                    # Salva as configurações carregadas (atualizando o arquivo)

# Cria um arquivo de configurações padrão, caso ele não exista
func make_default_config_file():
	config.save(CONFIG_FILE)

# Salva as configurações atuais no arquivo CONFIG_FILE
func save_settings():
	for section in settings.keys():
		for key in settings[section]:
			config.set_value(section, key, settings[section][key])
	config.save(CONFIG_FILE)

# Define e aplica a dificuldade do jogo
func set_difficulty(new_difficulty):
	difficulty = new_difficulty                         # Atualiza a variável de dificuldade
	settings["game"]["difficulty"] = difficulty         # Atualiza a configuração no dicionário
	save_settings()                                    # Salva as configurações

# Verifica se uma nova pontuação é um highscore e atualiza a lista se for
func check_highscore(new_score):
	for score in highscores:
		if new_score > score:
			highscores.pop_back()                      # Remove a menor pontuação da lista
			highscores.push_back(new_score)            # Adiciona a nova pontuação
			highscores.sort_custom(self, "sort_scores")  # Reordena a lista em ordem decrescente
			settings["game"]["highscores"] = highscores  # Atualiza a configuração no dicionário
			save_settings()                            # Salva as configurações
			return true                                # Retorna true se houve atualização
	return false                                       # Retorna false se não for highscore

# Define e aplica o volume da música
func set_music_volume(volume):
	if volume == -10:
		AudioServer.set_bus_mute(1, true)              # Se volume estiver no mínimo, silencia o canal de música
	else:
		AudioServer.set_bus_mute(1, false)             # Caso contrário, ativa o canal
		AudioServer.set_bus_volume_db(1, -10 + volume)   # Ajusta o volume do canal de música
	music_volume = volume
	settings["audio"]["music_volume"] = volume         # Atualiza a configuração no dicionário
	save_settings()                                    # Salva as configurações

# Define e aplica o volume dos efeitos sonoros (SFX)
func set_sfx_volume(volume):
	if volume == -10:
		AudioServer.set_bus_mute(2, true)              # Se volume estiver no mínimo, silencia o canal de SFX
	else:
		AudioServer.set_bus_mute(2, false)             # Caso contrário, ativa o canal
		AudioServer.set_bus_volume_db(2, -10 + volume)   # Ajusta o volume do canal de SFX
	sfx_volume = volume
	settings["audio"]["sfx_volume"] = volume           # Atualiza a configuração no dicionário
	save_settings()                                    # Salva as configurações
