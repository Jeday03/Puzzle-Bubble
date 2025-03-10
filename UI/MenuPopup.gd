extends Popup  # Extende a classe Popup, utilizada para exibir menus e telas de fim de jogo

var score = 0  # Variável que armazena a pontuação atual do jogador

# Função executada quando o botão de Reiniciar é pressionado
func _on_RestartButton_pressed():
	# Recarrega a cena atual para reiniciar o jogo
	get_tree().reload_current_scene()

# Função executada quando o botão de Menu é pressionado
func _on_MenuButton_pressed():
	# Muda a cena atual para o menu principal
	get_tree().change_scene("res://UI/MainMenu.tscn")

# Função executada quando o botão de Opções é pressionado
func _on_OptionsButton_pressed():
	# Exibe o menu de opções centralizado na tela
	$OptionsMenu.popup_centered()

# Função executada quando o botão de Sair é pressionado
func _on_QuitButton_pressed():
	# Encerra o jogo
	get_tree().quit()

# Função executada quando o botão de Voltar é pressionado
func _on_BackButton_pressed():
	# Oculta este pop-up, retornando à tela anterior
	hide()

# Função chamada quando a visibilidade do MenuPopup é alterada
func _on_MenuPopup_visibility_changed():
	# Habilita ou desabilita a capacidade de disparar da(s) entidade(s) do grupo "Player"
	# O método "set_fire" é chamado com o valor inverso da visibilidade atual do popup
	get_tree().call_group("Player", "set_fire", !visible)

# Função para configurar e exibir a tela de fim de jogo
func game_over(has_won):
	# Altera o título exibido de acordo com o resultado do jogo
	if has_won:
		$Panel/VBoxContainer/TitleLabel.text = "Victory!"
	else:
		$Panel/VBoxContainer/TitleLabel.text = "Game Over!"
	
	# Garante que a label de pontuação esteja visível
	$Panel/VBoxContainer/ScoreLabel.show()
	
	# Exibe o pop-up centralizado na tela
	popup_centered()
	
	# Se a pontuação atual for um highscore, exibe a label de highscore
	if GameState.check_highscore(score):
		$Panel/HighScoreLabel.show()

# Função que atualiza a pontuação exibida quando a pontuação é modificada
func _on_Score_updated_score(new_score):
	# Atualiza a variável local de pontuação com o novo valor
	score = new_score
	# Atualiza o texto da label para refletir a nova pontuação
	$Panel/VBoxContainer/ScoreLabel.text = "Your Score: %s" % score
