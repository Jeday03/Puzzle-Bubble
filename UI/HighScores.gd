extends Popup  # Este script estende a classe Popup, tornando-o uma janela pop-up

func _ready():
	# Obtém a quantidade de nós filhos dentro do container de scores (ScoreContainer)
	var scores = $VBoxContainer/CenterContainer/ScoreContainer.get_child_count()
	# Divide a quantidade total de filhos por 2. Isso pode ser feito porque cada pontuação
	# ocupa dois nós (por exemplo, um rótulo e um valor), logo, o número real de pontuações é a metade.
	scores /= 2  
	
	# Itera por cada índice de pontuação (de 0 até scores - 1)
	for score in scores:
		# Calcula o índice do nó que exibe o valor da pontuação.
		# Multiplicando o índice por 2 e somando 1, assume-se que os nós de texto das pontuações estão
		# posicionados em índices ímpares dentro do ScoreContainer.
		$VBoxContainer/CenterContainer/ScoreContainer.get_child((score*2)+1).text = str(GameState.highscores[score])
		
func _on_DoneButton_pressed():
	# Quando o botão "Done" for pressionado, oculta o pop-up
	hide()
