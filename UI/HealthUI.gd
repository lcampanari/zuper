extends Control

var heart_px_size_x = 15

var hit_points = 4 setget set_hit_points
var max_hit_points = 4  setget set_max_hit_points

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_hit_points(val):
	hit_points = clamp(val, 0, max_hit_points)
	set_hearts(hit_points)
	
func set_max_hit_points(val):
	max_hit_points = max(val, 1)
	self.hit_points = min(hit_points, max_hit_points)
	set_empty_hearts(max_hit_points)
	
func _ready():
	self.max_hit_points = PlayerStats.max_health
	self.hit_points = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hit_points")
	PlayerStats.connect("max_health_changed", self, "set_max_hit_points")

func set_hearts(hearts):
	if heartUIFull == null:
		pass
	heartUIFull.rect_size.x = hearts * heart_px_size_x
	
func set_empty_hearts(hearts):
	if heartUIEmpty == null:
		pass
	heartUIEmpty.rect_size.x = hearts * heart_px_size_x
