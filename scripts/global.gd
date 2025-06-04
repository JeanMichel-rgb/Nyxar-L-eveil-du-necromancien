extends Node

var game_start : bool = false
var metaux : float = 100
var pv : float = 100
var nb_monster_in_life : int = 0
var in_wave : bool = false
var pos_monsters : Array = []
var hide_gui : bool = false
var placing_tower : bool = false
var pierre : Array = []
var feu :Array = []
var vitesse_ratio = 1
var loading_game : bool = false

var automatic_evolution : bool = false
var monsters_evolutions : Dictionary = {
	"type1" = {
		"name" = "type1",
		"speed" = 1,
		"health" = 3,
		"damages" = 5,
		"scale" = 1.5,
		"resistance" = {
			"shock" = 1,      #choc
			"notch" = 1,      #entaille
			"lazer" = 1,      #laser
			"poison" = 1,     #poison
			"fire" = 1,       #feu
			"explosion" = 1   #explosion
			}
		},
	"type2" = {
		"name" = "type2",
		"health" = 1,
		"speed" = 2,
		"damages" = 5,
		"scale" = 1.5,
		"resistance" = {
			"shock" = 1,      #choc
			"notch" = 1,      #entaille
			"lazer" = 1,      #laser
			"poison" = 1,     #poison
			"fire" = 1,       #feu
			"explosion" = 1   #explosion
			}
		},
	"type3" = {
		"name" = "type3",
		"health" = 10,
		"speed" = .7,
		"damages" = 5,
		"scale" = 1.8,
		"resistance" = {
			"shock" = 1,      #choc
			"notch" = 1,      #entaille
			"lazer" = 1,      #laser
			"poison" = 1,     #poison
			"fire" = 1,       #feu
			"explosion" = 1   #explosion
			}
		}
	}

var damages_this_sequence : Dictionary = {
	"type1" = {
		"shock" = 0,      #choc
		"notch" = 0,      #entaille
		"lazer" = 0,      #laser
		"poison" = 0,     #poison
		"fire" = 0,       #feu
		"explosion" = 0   #explosion
		},
	"type2" = {
		"shock" = 0,      #choc
		"notch" = 0,      #entaille
		"lazer" = 0,      #laser
		"poison" = 0,     #poison
		"fire" = 0,       #feu
		"explosion" = 0   #explosion
		},
	"type3" = {
		"shock" = 0,      #choc
		"notch" = 0,      #entaille
		"lazer" = 0,      #laser
		"poison" = 0,     #poison
		"fire" = 0,       #feu
		"explosion" = 0   #explosion
		},
		
	}
