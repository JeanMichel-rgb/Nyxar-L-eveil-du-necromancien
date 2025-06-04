extends Node2D

@onready var book : Node2D = $Path2D/PathFollow2D/livre
var book_state : String = "couverture"
var mouse : bool = false
var mouse_p_l : bool = false
var mouse_p_r : bool = false
var page_index : int = 0
const page_max : int = 4

func _ready() -> void:
	#setup varables
	update_variables()

func _process(delta: float) -> void:
	if Global.automatic_evolution:
		show()
		move_menu()
		update_variables()
		update_menu()
	else :
		hide()

func move_menu():
	if mouse:
		$Path2D/PathFollow2D.progress_ratio += .05
	else :
		$Path2D/PathFollow2D.progress_ratio -= .05

func update_variables():
	if Input.is_action_just_pressed("clique gauche"):
		if mouse_p_l:
			page_index -= 1
		elif mouse_p_r:
			page_index += 1
	page_index = clamp(page_index,0,page_max)
	if page_index == 0:
		book_state = "couverture"
	elif page_index == page_max:
		book_state = "4e_couverture"
	else :
		book_state = "livre_ouvert"

func update_menu():
	#update book state
	book.scale = Vector2(1,1)*.775
	if book_state == "couverture":
		book.get_node("couverture").position = Vector2(174,5)
		book.get_node("pages").hide()
		book.get_node("monstres").hide()
	elif book_state == "livre_ouvert":
		book.get_node("couverture").position = Vector2(0,5)
		book.get_node("pages").show()
		book.get_node("monstres").show()
		costume_qui_change_trop_beaucoup_parceque_ils_sont_trop_jouli()
	elif book_state == "4e_couverture":
		book.get_node("couverture").position = Vector2(-172,5)
		book.get_node("pages").hide()
		book.get_node("monstres").hide()
	book.get_node("couverture").animation = book_state
	
	

func costume_qui_change_trop_beaucoup_parceque_ils_sont_trop_jouli():
	for i in 3:
		get_node("Path2D/PathFollow2D/livre/monstres/type"+str(i+1)).hide()
		if page_index == i+1:
			var my_name : String = "type"+str(i+1)
			var pv : float = Global.monsters_evolutions[my_name]["health"]
			var resistance : Dictionary = Global.monsters_evolutions[my_name]["resistance"]
			get_node("Path2D/PathFollow2D/livre/monstres/"+ my_name+"/ameliorations/arme_pouvoir").hide()
			get_node("Path2D/PathFollow2D/livre/monstres/"+ my_name+"/ameliorations/armure_epauliere").hide()
			get_node("Path2D/PathFollow2D/livre/monstres/"+ my_name+"/ameliorations/casque").hide()
			get_node("Path2D/PathFollow2D/livre/monstres/"+ my_name+"/ameliorations/zone_ailes").hide()
			get_node("Path2D/PathFollow2D/livre/monstres/type"+str(i+1)).show()
			get_node("Path2D/PathFollow2D/livre/pages/right").text = "points de vie : "+str(round(pv))+"\n\ndégats bruts : "+str(round(resistance["shock"]*100))+"%\n\ndégats de coupures : "+str(round(resistance["notch"]*100))+"%\n\ndégats de lazers : "+str(round(resistance["lazer"]*100))+"%\n\ndégats d'explosions : "+str(round(resistance["explosion"]*100))+"%\n\ndégats de brûlure : "+str(round(resistance["fire"]*100))+"%\n\ndégats d'empoisonnement : "+str(round(resistance["poison"]*100))+"%"
			
			if my_name == "type1":
				#region arme_pouvoir
				if resistance["lazer"] < 0.8:
					#$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.rotation = PI/2
					$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.show()
					
					if resistance["lazer"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.position = Vector2(12,-9)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.animation = "1"
					
					elif resistance["lazer"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.position = Vector2(12,0)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.animation = "2"
					
					elif resistance["lazer"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.position = Vector2(12,0)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.position = Vector2(12,0)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/arme_pouvoir.animation = "4"
				#endregion
				#region armure_epauliere
				if resistance["notch"] < 0.8:
					#$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.rotation = PI/2
					$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.show()
					if resistance["notch"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.position = Vector2.ZERO
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.animation = "1"
					
					elif resistance["notch"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.position = Vector2.ZERO
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.animation = "2"
					
					elif resistance["notch"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.position = Vector2.ZERO
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.position = Vector2.ZERO
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/armure_epauliere.animation = "4"
				#endregion
				#region casque
				if resistance["shock"] < 0.8:
					#$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.rotation = PI/2
					$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.show()
					if resistance["shock"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.position = Vector2(-8.5,.4)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.animation = "1"
					
					elif resistance["shock"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.position = Vector2(-10,.4)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.animation = "2"
					
					elif resistance["shock"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.position = Vector2(-13,.4)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.position = Vector2(-13,.4)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/casque.animation = "4"
				#endregion
				#region zone_ailes
				if resistance["explosion"] < 0.8:
					#$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.rotation = PI/2
					$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.show()
					if resistance["explosion"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.position = Vector2(-5,0)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.animation = "1"
					
					elif resistance["explosion"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.position = Vector2(-5,0)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.animation = "2"
					
					elif resistance["explosion"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.position = Vector2(-5,0)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.position = Vector2(-5,0)
						$Path2D/PathFollow2D/livre/monstres/type1/ameliorations/zone_ailes.animation = "4"
				#endregion
			
			if my_name == "type2":
				#region arme_pouvoir
				if resistance["lazer"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.show()
					
					if resistance["lazer"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.position = Vector2(11,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.animation = "1"
					
					elif resistance["lazer"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.position = Vector2(11,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.animation = "2"
					
					elif resistance["lazer"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.position = Vector2(11,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.position = Vector2(11,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/arme_pouvoir.animation = "4"
				#endregion
				#region armure_epauliere
				if resistance["notch"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.show()
					if resistance["notch"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.animation = "1"
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.position = Vector2.ZERO
					
					elif resistance["notch"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.position = Vector2(2.5,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.animation = "2"
					
					elif resistance["notch"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.animation = "3"
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.position = Vector2(9.1,0)
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.animation = "4"
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/armure_epauliere.position = Vector2(9.1,0)
				#endregion
				#region casque
				if resistance["shock"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.show()
					if resistance["shock"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.position = Vector2(-9.7,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.animation = "1"
					
					elif resistance["shock"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.position = Vector2(-9.7,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.animation = "2"
					
					elif resistance["shock"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.position = Vector2(-11.5,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.position = Vector2(-13,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/casque.animation = "4"
				#endregion
				#region zone_ailes
				if resistance["explosion"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.show()
					if resistance["explosion"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.position = Vector2(-4,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.animation = "1"
					
					elif resistance["explosion"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.position = Vector2(-4,0)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.animation = "2"
					
					elif resistance["explosion"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.position = Vector2(-4,-1)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.position = Vector2(-0.7,-1)
						$Path2D/PathFollow2D/livre/monstres/type2/ameliorations/zone_ailes.animation = "4"
				#endregion
			
			if my_name == "type3":
				#region arme_pouvoir
				if resistance["lazer"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.show()
					
					if resistance["lazer"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.position = Vector2(13,3)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.animation = "1"
					
					elif resistance["lazer"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.position = Vector2(13.6,5.5)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.animation = "2"
					
					elif resistance["lazer"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.position = Vector2(13.6,5.5)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.position = Vector2(16,1.5)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/arme_pouvoir.animation = "4"
				#endregion
				#region armure_epauliere
				if resistance["notch"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.show()
					if resistance["notch"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.position = Vector2(0.5,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.animation = "1"
					
					elif resistance["notch"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.position = Vector2(0.5,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.animation = "2"
					
					elif resistance["notch"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.position = Vector2(3,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.position = Vector2(4,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/armure_epauliere.animation = "4"
				#endregion
				#region casque
				if resistance["shock"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.show()
					if resistance["shock"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.position = Vector2(-10,-1)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.animation = "1"
					
					elif resistance["shock"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.position = Vector2(-7.3,-1.17)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.animation = "2"
				
					elif resistance["shock"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.position = Vector2(-9.5,-1.17)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.position = Vector2(-10.5,-1.17)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/casque.animation = "4"
				#endregion
				#region zone_ailes
				if resistance["explosion"] < 0.8:
					$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.show()
					if resistance["explosion"] > 0.6:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.position = Vector2(-7.5,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.animation = "1"
					
					elif resistance["explosion"] > 0.4:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.position = Vector2(-9.5,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.animation = "2"
					
					elif resistance["explosion"] > 0.2:
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.position = Vector2(-9.5,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.animation = "3"
					
					else :
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.position = Vector2(-9.5,0)
						$Path2D/PathFollow2D/livre/monstres/type3/ameliorations/zone_ailes.animation = "4"
			#endregion

#region mouse
func mouse_entered() -> void:
	mouse = true


func mouse_exited() -> void:
	mouse = false


func mouse_entered_p_r() -> void:
	mouse_p_r = true


func mouse_exited_p_r() -> void:
	mouse_p_r = false


func mouse_entered_p_l() -> void:
	mouse_p_l = true


func mouse_exited_p_l() -> void:
	mouse_p_l = false
#endregion

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout
