extends Popup  # Este script estende a classe Popup, criando uma janela pop-up para configurações ou seleção de dificuldade

func _ready():
	# Quando o Popup entra na cena, define o valor do SpinBox como a dificuldade atual armazenada em GameState
	$Panel/CenterContainer/HBoxContainer/SpinBox.value = GameState.difficulty

func _on_GoButton_pressed():
	# Ao pressionar o botão "Go", atualiza a dificuldade em GameState com o valor definido no SpinBox
	GameState.difficulty = int($Panel/CenterContainer/HBoxContainer/SpinBox.value)
	# Em seguida, muda para a cena do nível principal do jogo
	get_tree().change_scene("res://Level/Level.tscn")
