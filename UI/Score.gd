extends Panel  # Este script gerencia a exibição e atualização animada da pontuação do jogo

# Variável de pontuação, que ao ser alterada chama a função update_score (setter)
var score = 0 setget update_score

# Sinal emitido para notificar outras partes do jogo quando a pontuação é atualizada
signal updated_score

# Função setter que atualiza a pontuação de forma animada usando um Tween
func update_score(new_score):
	# Configura o Tween para interpolar a propriedade "text" do nó Label,
	# passando de 'score' até 'new_score' em 0.5 segundos, com transição linear e easing in
	$Tween.interpolate_property(
			$Label, "text",
			score, new_score, 
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()  # Inicia a animação do Tween

# Callback executado a cada passo (step) da interpolação do Tween
func _on_Tween_tween_step(_object, _key, _elapsed, value):
	# Arredonda o valor interpolado para o inteiro mais próximo (passo de 1.0)
	var current_score = stepify(value, 1.0)
	# Atualiza o texto do Label com o valor atual da pontuação
	$Label.text = str(current_score)
	# Emite o sinal updated_score com o valor atual para informar outras partes do jogo
	emit_signal("updated_score", current_score)

# Callback executado quando a animação do Tween é completamente finalizada
func _on_Tween_tween_all_completed():
	# Atualiza a variável 'score' para o valor final exibido no Label
	score = int($Label.text)
	# Emite o sinal updated_score com o valor final da pontuação
	emit_signal("updated_score", score)
