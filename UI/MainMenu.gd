extends Node2D  # Este script gerencia a interface principal do jogo, como menu de navegação

# Função chamada quando o botão "New Game" é pressionado
func _on_ButtonNewGame_pressed():
	# Exibe a janela pop-up para seleção de nível (LevelSelect) centralizada na tela
	$CanvasLayer/Control/LevelSelect.popup_centered()

# Função chamada quando o botão "Quit" é pressionado
func _on_ButtonQuit_pressed():
	# Encerra o jogo, fechando a aplicação
	get_tree().quit()

# Função chamada quando o botão "Options" é pressionado
func _on_Buttonoptions_pressed():
	# Exibe a janela pop-up de opções (OptionsMenu) centralizada na tela
	$CanvasLayer/Control/OptionsMenu.popup_centered()

# Função chamada quando o botão "High Score" é pressionado
func _on_ButtonHighScore_pressed():
	# Exibe a janela pop-up de pontuações altas (HighScores) centralizada na tela
	$CanvasLayer/Control/HighScores.popup_centered()
