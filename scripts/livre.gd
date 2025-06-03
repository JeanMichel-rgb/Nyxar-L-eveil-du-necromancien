extends Node2D

@onready var book : Node2D = $Path2D/PathFollow2D/livre
var book_state : String = "couverture"
var mouse : bool = false
var mouse_p_l : bool = false
var mouse_p_r : bool = false
var page_index : int = 0
const page_max : int = 57
var actual_max_page_index : int = 0
var previous_max_page_index : int = 0
var vague = 0
const mois : Array = ["Avril","Mai","Juin"]
const durée_mois : Array = [30,31,30]

var pages : Array = [
	#1er de couverture
	{
		"left" = "",
		
		"right" = ""
	},
	#region prelude
	#12 days
	{
		"left" = "Déjà 20 ans que je tiens ce 
		journal. Mais c'est la première
		fois que je vois quelque chose
		d'aussi étrange. Ce matin, je
		part au boulot en voiture. Il 
		faisait plein soleil. D'un coup, 
		l'obscurité masque tout, 
		comme si la nuit tombait. 
		Pourtant, il est 10h. Je pense 
		d'abord à une éclipse. Je 
		regarde mon téléphone, plus",
		
		"right" = "d'internet. Je ne comprenais 
		pas. En quelque minutes, 
		tout le monde fut dans les
		rues. Les gens étaient
		désemparés. Rapidement, les
		autorités calmèrent la
		population et chaque
		personne dut rentrer chez
		elle."
	},
	
	{
		"left" = "Rien n'a changé. La nuit est
		toujours présente. Mais que ce
		passe-t-il?",
		
		"right" = ""
	},
	
	{
		"left" = "Des marques inconnues sont
		apparues proche des cimetières.
		Elles irradient d'une lueur violette. 
		J'ai le préssentiment que c'est lié
		à l'évenement d'avant hier.",
		
		"right" = ""
	},
	
	{
		"left" = "Les tombes proches des
		marques ont été retrouvées
		ouvertes ... et vides. Tout le
		monde a peur.",
		
		"right" = ""
	},
	
	{
		"left" = "Des squelettes animés
		déhambulent dans les rues.
		J'ai l'impression d'être dans un
		livre de SF. Leurs yeux sont de
		la même couleur que les
		marques autour des
		cimetières. Tout est lié! C'est
		sûr désormais! L'armée à
		tenté de les abattre. Sans
		succès. Il a donc été décidé de
		capturer des squelettes pour
		découvrir :",
		
		"right" = "comment vivent-il? Qu'est-ce
		qui peut les détruire?"
	},
	
	{
		"left" = "Une voix grave, profonde,
		sombre, a appelé les
		squelettes a se rassembler.
		Des centaines de squelettes
		ont défilé dans les rues. La
		peur me tenaille. Quelque soit
		cette personne ou cette
		entité, elle ne semble pas
		pacifique.",
		
		"right" = ""
	},
	
	{
		"left" = "On va tous mourrir! Ce matin
		on vient de nous annoncer par
		haut parleur que la Chine a
		subie une attaque des
		squelettes et s'était
		inclinée ... EN 1h !!! 0
		SURVIVANTS! J'en suis
		abasourdi. La deuxième
		puissance mondiale, détruite
		en 1h! 
		ON VA TOUS MOURRIR!
		",
		
		"right" = "On nous a appris également
		que notre adversaire s'appelle
		'Le Nécromancien'! 
		Un mage qui réveille les morts !"
	},
	
	{
		"left" = "L'armée fortifie la ville. Nous
		devons être auto suffisant. Des
		chercheurs travaillent jours et
		nuits pour trouver quelque 
		chose d'efficace contre les
		squelettes.",
		
		"right" = ""
	},
	
	{
		"left" = "Les squelettes progressent
		très vite. D'après certains,
		l'humanité pourrait s'éteindre
		en quelques jours.
		 
		Nous sommes en train de
		couper la ville du monde
		exterieur.",
		
		"right" = ""
	},
	
	{
		"left" = "
		ENFIN! ILS L'ONT FAIT ! ILS ONT
		TROUVÉ UN TOUT NOUVEAU
		METAL CORROSIF CONTRE CES
		MONSTRES !

		On l'utilise pour
		créer des armes en ce moment
		même. Ces une course contre
		la montre !",
		
		"right" = ""
	},
	
	{
		"left" = "La ville est prête. Les
		fortifications sont solides. On a
		laissé une seule porte pour
		accèder à la ville. On est passé
		en économie de guerre. Tous
		les métiers ont été réattribués
		selon les capacitées de chacun:
		fermier, raffineur du minerai,
		soldat, et le mien, général de
		l'armée. Pourquoi moi? J'ai
		certe toujours été bon au jeux
		de stratégie,",
		
		"right" = "mais ça s'arrête là...
		Mon rôle est de déterminer
		quel tour de défense il faut
		installer, quand, et où.
		 
		PS: Ironiquement, les tours
		sont créées en partie à partir
		de résidus de monstres mort."
	},
	
	{
		"left" = "D'après nos informations,
		nous sommes les derniers
		survivants humains. Pourtant,
		aucun squelette en vue.
		 
		Maintenant devenu
		comandant, j'aurais surement
		beaucoup moins de temps
		pour écrire ce journal.",
		
		"right" = ""
	},
	#endregion
	#region sequence1
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "Aujourd'huit, un évenement
		étrange c'est produit.
		En tuant un squelette qui
		semble être leur chef, une
		croix s'aparantant à une
		tombe, et de tout évidence
		magique, est apparue.
		Impossible de s'en approcher:
		un feu violet brule dessus en
		permanence. J'ai un très
		mauvais préssentiment.",
		
		"right" = ""
	},
	#endregion
	#region sequence2
	{
		"left" = "Au jourd'hui, comme tous les
		autres jours, une vague de
		monstres à attaqué la ville.
		Seulement, cette fois, ce ne fut
		pas des squelettes, et ils ne
		semblaient pas venir de la
		cette Terre. Bizarre...",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "Encore. C'est ce que je me suis
		dit aujourd'hui après qu'une
		seconde tombe soit apparue.
		La couleur est différente, mais
		en dehors de cela, elles
		semblent identiques. Pourvu
		qu'elle soit la dernière !",
		
		"right" = ""
	},
	#endregion
	#region sequence3
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "Cela ne m'étonne même plus
		désormais :
		Après avoir été attaqué par un
		insecte plus imposant que les
		autres, et l'avoir vaincu, une
		tombe est apparue... 
		Je m'en doutais. Mais qu'est-ce
		qu'il prépare ?",
		
		"right" = ""
	},
	#endregion
	#region sequence4
	{
		"left" = "BON SANG !
		IL nous à attaqué avec NOS
		troupes. Ces vaillants guerrier
		morts au combat pour sauver
		l'humanité on bien faillit nous
		détruire ! Ce 'nécromancien'
		n'a-t-il donc aucun honneur? ",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	#endregion
	#region sequence5
	{
		"left" = "JE N'Y CROIS PAS !
		Il a réussit à reprogrammer les
		Robots que NOUS avions créé
		pour LE vaincre !!!
		IL n'a vraiment honte de rien !",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	#endregion
	#region sequence6
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	
	{
		"left" = "",
		
		"right" = ""
	},
	#endregion
	#region sequence_necromancien
	{
		"left" = "Après tout ce temps sans que
		les tombes ne réagissent à
		toutes nos tentatives, elles se
		sont illuminés ! tous les
		monstres vus jusqu'à ce jour
		sont repassés les uns après les
		autres ! J'ai le préssentiment
		que cela n'augure rien de
		bon...",
		
		"right" = ""
	},
	
	{
		"left" = "Le 26 Mai 2484 restera dans les
		mémoires comme étant le jour
		de la première victoire
		humaine ! Le Nécromancien
		nous à bien fait peur avec son
		entrée fracassante ! La nuit
		est devenue si noir qu'on ne
		voyait que lui ! lorsqu'il passait
		sur une tombe, il réssuscitait
		le monstre correspondant.
		Cependant, malgré tout, notre",
		
		"right" = "puissance de feu l'a fait fuir
		dans un portail qu'il à créé.
		On aurait aimé en finir avec
		lui, mais au moins, on sait
		maintenant qu'il n'est pas
		invincible, qu'on peut le
		vaincre !
		Peut être alors que l'humanité
		à une chance !"
	},
	#endregion
	#4e de couverture
	{
		"left" = "",
		
		"right" = ""
	},
]

func _ready() -> void:
	#setup varables
	vague = 0
	update_variables()
	previous_max_page_index = actual_max_page_index-1
	book.get_node("notification").hide()
	notification_animation()

func _process(delta: float) -> void:
	move_menu()
	update_variables()
	update_menu()

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
	actual_max_page_index = 12+vague

func update_menu():
	#update book state
	book.scale = Vector2(1,1)*.775
	if book_state == "couverture":
		book.get_node("couverture").position = Vector2(174,5)
		book.get_node("pages").hide()
	elif book_state == "livre_ouvert":
		book.get_node("couverture").position = Vector2(0,5)
		book.get_node("pages").show()
	elif book_state == "4e_couverture":
		book.get_node("couverture").position = Vector2(-172,5)
		book.get_node("pages").hide()
	book.get_node("couverture").animation = book_state
	#update pages
		#left
	book.get_node("pages/left").text = pages[page_index]["left"]
		#right
	book.get_node("pages/right").text = pages[page_index]["right"]
	#update date
	var date : int = 8+page_index
	var moi_index : int = 0
	while date % (durée_mois[moi_index]+1) != date:
		date -= durée_mois[moi_index]
		moi_index += 1
	book.get_node("pages/date").text = str(date)+" "+str(mois[moi_index])+" 2484"
	
	#show/hide "marque étrange"
	if date == 11 and moi_index == 0:
		book.get_node("pages/marque_étrange").show()
	else:
		book.get_node("pages/marque_étrange").hide()
	if page_index > actual_max_page_index:
		book.get_node("pages/left").hide()
		book.get_node("pages/right").hide()
		book.get_node("pages/marque_étrange").hide()
	else:
		book.get_node("pages/left").show()
		book.get_node("pages/right").show()
	if previous_max_page_index != actual_max_page_index:
		if pages[actual_max_page_index]["left"] != "":
			new_page_notification()
		previous_max_page_index = actual_max_page_index

func new_page_notification():
	book.get_node("notification").show()
	while not mouse or page_index != actual_max_page_index:
		await sleep()
	book.get_node("notification").hide()

func notification_animation():
	book.get_node("notification").modulate = Color(1,1,1)*2
	while true:
		for i in 5:
			book.get_node("notification").modulate += Color(1,1,1)*3/8
			await sleep(.05)
		for i in 5:
			book.get_node("notification").modulate -= Color(1,1,1)*3/8
			await sleep(.05)

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
