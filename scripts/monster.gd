extends PathFollow2D
var my_name : String   #ex : squelette_1 (nom du costume)
var vitesse
var pv
var dégats
var num   #numéro du monstre
var SPEED = 130 #pow(10,pow(10,100))
var on_fire : bool = false
var frame_en_flamme_en_cours = false
var poisoned : bool = false
var vulnérable_time : float = 0
var paralized : bool = false
var dégats_poison : float = 1
var dégats_feu : float = 1
var vulnerable_ = false
@onready var parent = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var grave = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("tombe")

#1:   arme
#2:   casque
#3:   aile
#4:   armure


var all_monsters : Dictionary = {
	#region squelette
	"squelette_1" = {
		"name" = "squelette_1",
		"speed" = 1,
		"health" = 3,
		"damages" = 1,
		"scale" = 1
		},
	"squelette_2" = {
		"name" = "squelette_2",
		"speed" = 2,
		"health" = 1,
		"damages" = .7,
		"scale" = .9
		},
	"squelette_3" = {
		"name" = "squelette_3",
		"speed" = .7,
		"health" = 10,
		"damages" = 3,
		"scale" = 1.5
		},
	"squelette_boss" = {
		"name" = "squelette_boss",
		"speed" = .3,
		"health" = 50,
		"damages" = 50,
		"scale" = 1.7
		},
	#endregion
	#region s2
	"s2_1" = {
		"name" = "s2_1",
		"speed" = 1,
		"health" = 7,
		"damages" = 2,
		"scale" = 1
		},
	"s2_2" = {
		"name" = "s2_2",
		"speed" = 2,
		"health" = 6,
		"damages" = 1.5,
		"scale" = .9
		},
	"s2_3" = {
		"name" = "s2_3",
		"speed" = .7,
		"health" = 25,
		"damages" = 6,
		"scale" = 1.5
		},
	"s2_boss" = {
		"name" = "s2_boss",
		"speed" = .3,
		"health" = 190,
		"damages" = 50,
		"scale" = 1.7
		},
	#endregion
	#region insecte
	"insecte_1" = {
		"name" = "insecte_1",
		"speed" = 2,
		"health" = 10,
		"damages" = 1,
		"scale" = 1
		},
	"insecte_2" = {
		"name" = "insecte_2",
		"speed" = 2.5,
		"health" = 10,
		"damages" = 1,
		"scale" = 1
		},
	"insecte_3" = {
		"name" = "insecte_3",
		"speed" = 1,
		"health" = 32,
		"damages" = 1,
		"scale" = 1.25
		},
	"insecte_boss" = {
		"name" = "insecte_boss",
		"speed" = 1.25,
		"health" = 80,
		"damages" = 50,
		"scale" = 1.7
		},
	#endregion
	#region soldat
	"soldat_1" = {
		"name" = "soldat_1",
		"speed" = 1,
		"health" = 25,
		"damages" = 1,
		"scale" = 1.5
		},
	"soldat_2" = {
		"name" = "soldat_2",
		"speed" = 1,
		"health" = 40,
		"damages" = 2,
		"scale" = 1.5
		},
	"soldat_3" = {
		"name" = "soldat_3",
		"speed" = .7,
		"health" = 50,
		"damages" = 3,
		"scale" = 1.5
		},
	"soldat_4" = {
		"name" = "soldat_4",
		"speed" = .7,
		"health" = 70,
		"damages" = 6,
		"scale" = 1.5
		},
	"soldat_boss" = {
		"name" = "soldat_boss",
		"speed" = 1,
		"health" = 200,
		"damages" = 50,
		"scale" = 1.8
		},
	#endregion
	#region bot
	"bot_1" = {
		"name" = "bot_1",
		"speed" = 1,
		"health" = 45,
		"damages" = 2,
		"scale" = 1
		},
	"bot_2" = {
		"name" = "bot_2",
		"speed" = 2,
		"health" = 25,
		"damages" = 1.5,
		"scale" = .9
		},
	"bot_3" = {
		"name" = "bot_3",
		"speed" = .6,
		"health" = 100,
		"damages" = 6,
		"scale" = 1.3
		},
	"bot_boss" = {
		"name" = "bot_boss",
		"speed" = .3,
		"health" = 400,
		"damages" = 50,
		"scale" = 1.8
		},
	#endregion
	#region necromancien
	"dragon_1" = {
		"name" = "dragon_1",
		"speed" = 1,
		"health" = 100,
		"damages" = 5,
		"scale" = 1
		},
	"dragon_2" = {
		"name" = "dragon_2",
		"speed" = 2,
		"health" = 45,
		"damages" = 5,
		"scale" = .9
		},
	"dragon_3" = {
		"name" = "dragon_3",
		"speed" = .5,
		"health" = 200,
		"damages" = 6,
		"scale" = 1.5
		},
	"necromancien" = {
		"name" = "necromancien",
		"speed" = .2,
		"health" = 1000,
		"damages" = 1000,
		"scale" = 2
		},
	#region boss revive
	"squelette_boss_revive" = {
		"name" = "squelette_boss",
		"speed" = .2,
		"health" = 500,
		"damages" = 100,
		"scale" = 1.7
		},
	
	"s2_boss_revive" = {
		"name" = "s2_boss",
		"speed" = .2,
		"health" = 500,
		"damages" = 100,
		"scale" = 1.7
		},
	
	"insecte_boss_revive" = {
		"name" = "insecte_boss",
		"speed" = .2,
		"health" = 500,
		"damages" = 100,
		"scale" = 1.7
		},
	
	"soldat_boss_revive" = {
		"name" = "soldat_boss",
		"speed" = .2,
		"health" = 500,
		"damages" = 100,
		"scale" = 1.7
		},
	
	"bot_boss_revive" = {
		"name" = "bot_boss",
		"speed" = .2,
		"health" = 500,
		"damages" = 100,
		"scale" = 1.7
		}
	
	#endregion
	#endregion
	}

var bases_statistics : Dictionary = {}

var resistance : Dictionary = {
	"shock" = 1,      #choc  // casque
	"notch" = 1,      #entaille  //  epauliere
	"lazer" = 1,      #laser  //  pouvoir
	"explosion" = 1,   #explosion  //  zone
	"poison" = 1,     #poison
	"fire" = 1       #feu
	}

func _ready() -> void:
	$"Monster/costume/améliorations/arme_pouvoir".hide()
	$"Monster/costume/améliorations/armure_epauliere".hide()
	if parent is SubViewport:
		parent = parent.get_parent()
	if Global.automatic_evolution:
		bases_statistics = Global.monsters_evolutions[my_name]
		resistance = Global.monsters_evolutions[my_name]["resistance"]
	else :
		bases_statistics = all_monsters[my_name]
	vitesse = bases_statistics["speed"]
	pv = float(bases_statistics["health"])
	dégats = bases_statistics["damages"]
	scale = Vector2(1,1) * bases_statistics["scale"]
	$Monster/costume/AnimatedSprite2D.animation = my_name
	$StaticBody2D.pv = pv
	$health/health_bar.max_value = float(bases_statistics["health"])
	poison()
	$effets/feu.hide()
	$"effets/vulnérable".hide()
	$effets/poison.hide()
	if my_name == "dragon_1" or my_name == "dragon_2" or my_name == "dragon_3":
		$Monster/costume/AnimatedSprite2D.rotation = deg_to_rad(270)
	
	
	costume_qui_change_trop_beaucoup_parceque_ils_sont_trop_jouli()

func costume_qui_change_trop_beaucoup_parceque_ils_sont_trop_jouli():
	$"Monster/costume/améliorations/arme_pouvoir".hide()
	$"Monster/costume/améliorations/armure_epauliere".hide()
	$"Monster/costume/améliorations/casque".hide()
	$"Monster/costume/améliorations/zone_ailes".hide()
	if Global.automatic_evolution:
		if my_name == "type1":
			#region arme_pouvoir
			if resistance["lazer"] < 0.8:
				
				if resistance["lazer"] > 0.6:
					pass
				
				elif resistance["lazer"] > 0.4:
					pass
				
				elif resistance["lazer"] > 0.2:
					pass
				
				else :
					pass
			#endregion
			#region armure_epauliere
			if resistance["notch"] < 0.8:
				
				if resistance["notch"] > 0.6:
					pass
				
				elif resistance["notch"] > 0.4:
					pass
				
				elif resistance["notch"] > 0.2:
					pass
				
				else :
					pass
			#endregion
			#region casque
			if resistance["shock"] < 0.8:
				
				if resistance["shock"] > 0.6:
					pass
				
				elif resistance["shock"] > 0.4:
					pass
				
				elif resistance["shock"] > 0.2:
					pass
				
				else :
					pass
			#endregion
			#region zone_ailes
			if resistance["explosion"] < 0.8:
				
				if resistance["explosion"] > 0.6:
					pass
				
				elif resistance["explosion"] > 0.4:
					pass
				
				elif resistance["explosion"] > 0.2:
					pass
				
				else :
					pass
			#endregion
		
		if my_name == "type2":
			#region arme_pouvoir
			if resistance["lazer"] < 0.8:
				$"Monster/costume/améliorations/arme_pouvoir".show()
				
				if resistance["lazer"] > 0.6:
					$"Monster/costume/améliorations/arme_pouvoir".scale = Vector2(2,1.3)
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-1,118.075)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "2_1"
				
				elif resistance["lazer"] > 0.4:
					$"Monster/costume/améliorations/arme_pouvoir".scale = Vector2(2,1.3)
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-1,118.075)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "2_2"
				
				elif resistance["lazer"] > 0.2:
					$"Monster/costume/améliorations/arme_pouvoir".scale = Vector2(2,1.3)
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-1,118.075)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "2_3"
				
				else :
					$"Monster/costume/améliorations/arme_pouvoir".scale = Vector2(2,1.3)
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-1,118.075)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "2_4"
			#endregion
			#region armure_epauliere
			if resistance["notch"] < 0.8:
				$"Monster/costume/améliorations/armure_epauliere".show()
				if resistance["notch"] > 0.6:
					$"Monster/costume/améliorations/armure_epauliere".animation = "2_1"
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,10)
				
				elif resistance["notch"] > 0.4:
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,40)
					$"Monster/costume/améliorations/armure_epauliere".animation = "2_2"
				
				elif resistance["notch"] > 0.2:
					$"Monster/costume/améliorations/armure_epauliere".animation = "2_3"
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,110)
				
				else :
					$"Monster/costume/améliorations/armure_epauliere".animation = "2_4"
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,110)
			#endregion
			#region casque
			if resistance["shock"] < 0.8:
				$"Monster/costume/améliorations/casque".show()
				if resistance["shock"] > 0.6:
					$"Monster/costume/améliorations/casque".position = Vector2(1.2,-70)
					$"Monster/costume/améliorations/casque".animation = "2_1"
				
				elif resistance["shock"] > 0.4:
					$"Monster/costume/améliorations/casque".position = Vector2(1.2,-70)
					$"Monster/costume/améliorations/casque".animation = "2_2"
				
				elif resistance["shock"] > 0.2:
					$"Monster/costume/améliorations/casque".position = Vector2(1.2,-90)
					$"Monster/costume/améliorations/casque".animation = "2_3"
				
				else :
					$"Monster/costume/améliorations/casque".position = Vector2(1.2,-110)
					$"Monster/costume/améliorations/casque".animation = "2_4"
			#endregion
			#region zone_ailes
			if resistance["explosion"] < 0.8:
				$"Monster/costume/améliorations/zone_ailes".show()
				if resistance["explosion"] > 0.6:
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(0,-10)
					$"Monster/costume/améliorations/zone_ailes".animation = "2_1"
				
				elif resistance["explosion"] > 0.4:
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(0,-10)
					$"Monster/costume/améliorations/zone_ailes".animation = "2_2"
				
				elif resistance["explosion"] > 0.2:
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(0,-10)
					$"Monster/costume/améliorations/zone_ailes".animation = "2_3"
				
				else :
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(0,25)
					$"Monster/costume/améliorations/zone_ailes".animation = "2_4"
			#endregion
		
		if my_name == "type3":
			#region arme_pouvoir
			if resistance["lazer"] < 0.8:
				$"Monster/costume/améliorations/arme_pouvoir".show()
				
				if resistance["lazer"] > 0.6:
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-20,140)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "3_1"
				
				elif resistance["lazer"] > 0.4:
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-50,150)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "3_2"
				
				elif resistance["lazer"] > 0.2:
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-50,150)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "3_3"
				
				else :
					$"Monster/costume/améliorations/arme_pouvoir".position = Vector2(-20,180)
					$"Monster/costume/améliorations/arme_pouvoir".animation = "3_4"
			#endregion
			#region armure_epauliere
			if resistance["notch"] < 0.8:
				$"Monster/costume/améliorations/armure_epauliere".show()
				if resistance["notch"] > 0.6:
					$"Monster/costume/améliorations/armure_epauliere".animation = "3_1"
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,20)
				
				elif resistance["notch"] > 0.4:
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,20)
					$"Monster/costume/améliorations/armure_epauliere".animation = "3_2"
				
				elif resistance["notch"] > 0.2:
					$"Monster/costume/améliorations/armure_epauliere".animation = "3_3"
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,43)
				
				else :
					$"Monster/costume/améliorations/armure_epauliere".animation = "3_4"
					$"Monster/costume/améliorations/armure_epauliere".position = Vector2(0,53)
			#endregion
			#region casque
			if resistance["shock"] < 0.8:
				$"Monster/costume/améliorations/casque".show()
				if resistance["shock"] > 0.6:
					$"Monster/costume/améliorations/casque".scale = Vector2(1,1) * 1.1
					$"Monster/costume/améliorations/casque".position = Vector2(13,-80)
					$"Monster/costume/améliorations/casque".animation = "3_1"
				
				elif resistance["shock"] > 0.4:
					$"Monster/costume/améliorations/casque".scale = Vector2(1,1) * 1.1
					$"Monster/costume/améliorations/casque".position = Vector2(13,-50)
					$"Monster/costume/améliorations/casque".animation = "3_2"
			
				elif resistance["shock"] > 0.2:
					$"Monster/costume/améliorations/casque".scale = Vector2(1,1) * 1.1
					$"Monster/costume/améliorations/casque".position = Vector2(13,-80)
					$"Monster/costume/améliorations/casque".animation = "3_3"
				
				else :
					$"Monster/costume/améliorations/casque".scale = Vector2(1,1) * 1.1
					$"Monster/costume/améliorations/casque".position = Vector2(13,-90)
					$"Monster/costume/améliorations/casque".animation = "3_4"
			#endregion
			#region zone_ailes
			if resistance["explosion"] < 0.8:
				$"Monster/costume/améliorations/zone_ailes".show()
				if resistance["explosion"] > 0.6:
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(20,-60)
					$"Monster/costume/améliorations/zone_ailes".animation = "3_1"
				
				elif resistance["explosion"] > 0.4:
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(20,-80)
					$"Monster/costume/améliorations/zone_ailes".animation = "3_2"
				
				elif resistance["explosion"] > 0.2:
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(20,-80)
					$"Monster/costume/améliorations/zone_ailes".animation = "3_3"
				
				else :
					$"Monster/costume/améliorations/zone_ailes".position = Vector2(20,-80)
					$"Monster/costume/améliorations/zone_ailes".animation = "3_4"
			#endregion

func _process(delta: float) -> void:
	vulnerable()
	vulnérable_time -= delta
	var s : float = 1
	for i in $touche_neige.get_overlapping_areas():
		if i.is_in_group("neige"): s /= 2
		if i.is_in_group("vulnérable") : vulnérable_time = 1
		
	if vulnérable_time > 0 and pv != null:
		var damages = (pv - $StaticBody2D.pv)*2
		pv -= damages
		$StaticBody2D.pv = pv
		vulnerable_ = true
	else :
		pv = $StaticBody2D.pv
		vulnerable_ = false
	if pv > 0 :
		if not paralized:
			if progress_ratio < 1 :
				if Global.pierre.find(get_node("StaticBody2D")) == -1 :
					progress += vitesse * delta * SPEED * Global.vitesse_ratio * s
				Global.pos_monsters[num] = global_position
				await feu()
			else :
				Global.pv -=dégats
				Global.nb_monster_in_life -=1
				Global.pos_monsters[num] = Vector2.ZERO
				death()
	else :
		boss_grave()
		Global.nb_monster_in_life -=1
		reward()
		Global.pos_monsters[num] = Vector2.ZERO
		death()
	$health.global_rotation = 0
	$health/health_bar.value = pv
	var c = fmod(pv, float(float(bases_statistics["health"]))/2.0)/(float(bases_statistics["health"])/2.0)
	if pv == float(bases_statistics["health"]):
		c = Color(0,1,0)
	elif pv >= float(bases_statistics["health"])/2.0:
		c = Color(1-c, 1, 0)
	else :
		c = Color(1, c, 0)
	$health/health_bar.modulate = c

func death():
	queue_free()

func boss_grave():
	#create a grave
	var self_name : String = bases_statistics["name"]
	if ((	self_name == "squelette_boss" or
			self_name == "s2_boss" or
			self_name == "insecte_boss" or
			self_name == "soldat_boss" or
			self_name == "bot_boss") and
		(	parent.actual_sequence != 5 or parent.actual_wave != 6)):
		
		var new_grave = (load("res://scenes/tombe.tscn")as PackedScene).instantiate()
		new_grave.grave_type = self_name
		new_grave.advance = progress
		grave.add_child(new_grave)
		new_grave.global_position = global_position

func reward():
	if not Global.automatic_evolution:
		if parent.actual_sequence == 0 : 
			Global.metaux +=2.75
		elif parent.actual_sequence == 1 :
			Global.metaux +=3
		if parent.actual_sequence == 2 : 
			Global.metaux +=2
		elif parent.actual_sequence == 3 :
			Global.metaux +=2
	else :
		Global.metaux += 1

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout

func feu():
	if not frame_en_flamme_en_cours :
		for test in Global.feu :  
			for possibility in Global.feu : 
				if test[0] == $StaticBody2D :
					if test[1] > 0 : 
						test[1] -=1
						if Global.automatic_evolution:
							if pv > 0 and pv < dégats_feu *resistance["fire"]:
								Global.damages_this_sequence[str(bases_statistics["name"])]["fire"] += dégats_feu *resistance["fire"]
							else :
								Global.damages_this_sequence[str(bases_statistics["name"])]["fire"] += dégats_feu *resistance["fire"]
						$StaticBody2D.pv -= dégats_feu *resistance["fire"]
						frame_en_flamme_en_cours = true
						feu_animation()
						await sleep(1)
						frame_en_flamme_en_cours =false

func feu_animation():
	$effets/feu.show()
	$effets/feu.modulate.a = float(0.001)
	for i in 10 :
		$effets/feu.play("feu")
		$effets/feu.modulate.a += float(.2)
		await sleep(.03)
	for j in 10 :
		$effets/feu.modulate.a -= float(.2)
		await sleep(.03)

func poison():
	while not poisoned:
		await sleep()
	while true:
		await poison_animation()
		await sleep(.2)

func poison_animation():
	$effets/poison.show()
	$effets/poison.modulate.a = float(0.001)
	for i in 10 :
		$effets/poison.play("poison")
		$effets/poison.modulate.a += float(.2)
		await sleep(.04)
	if Global.automatic_evolution:
		if pv > 0 and pv < dégats_poison *resistance["poison"]:
			Global.damages_this_sequence[str(bases_statistics["name"])]["poison"] += dégats_poison *resistance["poison"]
		else :
			Global.damages_this_sequence[str(bases_statistics["name"])]["poison"] += dégats_poison *resistance["poison"]
	$StaticBody2D.pv -= dégats_poison *resistance["poison"]
	for j in 10 :
		$effets/poison.modulate.a -= float(.2)
		await sleep(.04)

func paralysis():
	paralized = true
	for i in 20:
		$Monster.position = Vector2(randi_range(-1,1),randi_range(-1,1))
		await sleep(.05)
	$Monster.position = Vector2.ZERO
	paralized = false
	
func vulnerable():
	if vulnerable_:
		$"effets/vulnérable".show()

	else:
		$"effets/vulnérable".hide()
