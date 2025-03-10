extends Popup  # Este script estende a classe Popup para exibir um menu de opções como uma janela pop-up

func _ready():
	# Quando o pop-up é carregado, inicializa os controles com os valores atuais do GameState
	$Panel/VBoxContainer/MusicSlider.value = GameState.music_volume         # Define o valor do slider de música
	$Panel/VBoxContainer/SoundSlider.value = GameState.sfx_volume            # Define o valor do slider de efeitos sonoros (SFX)
	$Panel/VBoxContainer/CenterContainer/GridContainer/FullscreenButton.pressed = GameState.fullscreen  # Define o estado do botão de tela cheia
	$Panel/VBoxContainer/CenterContainer/GridContainer/SymbolButton.pressed = GameState.symbols_mode      # Define o estado do botão de modo de símbolos

func _on_DoneButton_pressed():
	# Quando o botão "Done" é pressionado, oculta o pop-up
	hide()

func _on_FullscreenButton_pressed():
	# Alterna o estado de tela cheia no GameState sempre que o botão é pressionado
	GameState.fullscreen = !GameState.fullscreen

func _on_SoundSlider_value_changed(value):
	# Atualiza o volume dos efeitos sonoros no GameState conforme o slider é ajustado
	GameState.sfx_volume = value

func _on_MusicSlider_value_changed(value):
	# Atualiza o volume da música no GameState conforme o slider é ajustado
	GameState.music_volume = value

func _on_SymbolButton_toggled(button_pressed):
	# Atualiza o modo de símbolos no GameState com base no estado do botão
	GameState.symbols_mode = button_pressed
