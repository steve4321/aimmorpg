extends Node
## Breeding System Unit Tests
## Run via scenes/test_scene.tscn in Godot 4

var _pass_count: int = 0
var _fail_count: int = 0


func _ready() -> void:
	print("\n========================================")
	print("=== Breeding System Tests ===")
	print("========================================\n")

	# --- PlantData tests ---
	print("--- PlantData ---")
	test_all_species_have_family_id()
	test_all_species_have_genus_id()
	test_seed_packs_species_exist()
	test_discovery_table_species_exist()
	test_get_family_id()
	test_get_genus_id()
	test_total_species_count()
	test_no_duplicate_species()

	# --- GeneSystem tests ---
	print("\n--- GeneSystem ---")
	test_compute_compatibility_same_species()
	test_compute_compatibility_same_genus()
	test_compute_compatibility_same_family()
	test_compute_compatibility_same_group()
	test_compute_compatibility_cross_group()
	test_breed_returns_valid_result()
	test_breed_color_in_range()
	test_blend_color_incomplete_dominance()
	test_can_breed_across_groups_flower_succulent()
	test_can_breed_across_groups_succulent_cactus()

	# --- GameState tests ---
	print("\n--- GameState ---")
	test_initial_seeds()
	test_seed_pack_unlock_at_milestone()
	test_serialization_roundtrip()

	print("\n========================================")
	print("=== Results: %d passed, %d failed ===" % [_pass_count, _fail_count])
	print("========================================\n")

	# Auto-quit after tests (useful for headless runs)
	if _fail_count == 0:
		print("All tests passed!")
	else:
		push_error("%d test(s) FAILED" % _fail_count)


func _assert(condition: bool, test_name: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % test_name)
	else:
		_fail_count += 1
		push_error("  FAIL: %s" % test_name)


# ============================================================
# PlantData Tests
# ============================================================

func test_all_species_have_family_id() -> void:
	var all_types: Array = PlantData.get_all_types()
	var missing: Array = []
	for type in all_types:
		var data: Dictionary = PlantData.get_data(type)
		if not data.has("family_id"):
			missing.append(type)
	_assert(missing.is_empty(), "all species have family_id (missing: %s)" % [str(missing)])


func test_all_species_have_genus_id() -> void:
	var all_types: Array = PlantData.get_all_types()
	var missing: Array = []
	for type in all_types:
		var data: Dictionary = PlantData.get_data(type)
		if not data.has("genus_id"):
			missing.append(type)
	_assert(missing.is_empty(), "all species have genus_id (missing: %s)" % [str(missing)])


func test_seed_packs_species_exist() -> void:
	var all_types: Array = PlantData.get_all_types()
	var missing: Array = []
	for pack_id in PlantData.SEED_PACKS:
		var pack: Dictionary = PlantData.SEED_PACKS[pack_id]
		var species_list: Array = pack.get("species", [])
		for species in species_list:
			if not species in all_types:
				missing.append("%s->%s" % [pack_id, species])
	_assert(missing.is_empty(), "seed_packs species exist in PLANT_DATABASE (missing: %s)" % [str(missing)])


func test_discovery_table_species_exist() -> void:
	var all_types: Array = PlantData.get_all_types()
	var missing: Array = []
	for key in PlantData.DISCOVERY_TABLE:
		var entry: Dictionary = PlantData.DISCOVERY_TABLE[key]
		var results: Array = entry.get("results", [])
		for result in results:
			if not result in all_types:
				missing.append("%s->%s" % [key, result])
	_assert(missing.is_empty(), "discovery_table results exist in PLANT_DATABASE (missing: %s)" % [str(missing)])


func test_get_family_id() -> void:
	var family := PlantData.get_family_id("rose_gallica")
	var expected := PlantData.PlantFamily.ROSACEAE
	_assert(family == expected, "get_family_id('rose_gallica') == ROSACEAE (got %d)" % family)

	var orchid_family := PlantData.get_family_id("orchid_wild")
	_assert(orchid_family == PlantData.PlantFamily.ORCHIDACEAE,
		"get_family_id('orchid_wild') == ORCHIDACEAE (got %d)" % orchid_family)


func test_get_genus_id() -> void:
	var genus := PlantData.get_genus_id("rose_gallica")
	_assert(genus == "rosa", "get_genus_id('rose_gallica') == 'rosa' (got '%s')" % genus)

	var genus2 := PlantData.get_genus_id("sunflower_wild")
	_assert(genus2 == "helianthus", "get_genus_id('sunflower_wild') == 'helianthus' (got '%s')" % genus2)


func test_total_species_count() -> void:
	var count := PlantData.get_all_types().size()
	_assert(count == 105, "PLANT_DATABASE has 105 entries (got %d)" % count)


func test_no_duplicate_species() -> void:
	# Verify each key appears exactly once by counting occurrences in the raw dictionary
	var all_types: Array = PlantData.get_all_types()
	var seen: Dictionary = {}
	var duplicates: Array = []
	for type in all_types:
		if seen.has(type):
			duplicates.append(type)
		seen[type] = true
	_assert(duplicates.is_empty(), "no duplicate keys in PLANT_DATABASE (duplicates: %s)" % [str(duplicates)])


# ============================================================
# GeneSystem Tests
# ============================================================

func test_compute_compatibility_same_species() -> void:
	var compat := GeneSystem.compute_compatibility("rose_gallica", "rose_gallica")
	_assert(compat == GeneSystem.COMPAT_SAME_SPECIES,
		"same species returns COMPAT_SAME_SPECIES (%d, got %d)" % [GeneSystem.COMPAT_SAME_SPECIES, compat])


func test_compute_compatibility_same_genus() -> void:
	# rose_gallica and rose_canina both have genus_id "rosa"
	var compat := GeneSystem.compute_compatibility("rose_gallica", "rose_canina")
	_assert(compat == GeneSystem.COMPAT_SAME_GENUS,
		"same genus diff species returns COMPAT_SAME_GENUS (%d, got %d)" % [GeneSystem.COMPAT_SAME_GENUS, compat])


func test_compute_compatibility_same_family() -> void:
	# daisy_wild (bellis, ASTERACEAE) and sunflower_wild (helianthus, ASTERACEAE)
	# same family, different genus → COMPAT_SAME_FAMILY
	var compat := GeneSystem.compute_compatibility("daisy_wild", "sunflower_wild")
	_assert(compat == GeneSystem.COMPAT_SAME_FAMILY,
		"same family diff genus returns COMPAT_SAME_FAMILY (%d, got %d)" % [GeneSystem.COMPAT_SAME_FAMILY, compat])


func test_compute_compatibility_same_group() -> void:
	# rose_gallica (ROSACEAE, ROSE group) and peony (PAEONIACEAE, ROSE group)
	# same group, different family → COMPAT_SAME_GROUP
	var compat := GeneSystem.compute_compatibility("rose_gallica", "peony")
	_assert(compat == GeneSystem.COMPAT_SAME_GROUP,
		"same group diff family returns COMPAT_SAME_GROUP (%d, got %d)" % [GeneSystem.COMPAT_SAME_GROUP, compat])


func test_compute_compatibility_cross_group() -> void:
	# rose_gallica (ROSE group) and daisy_wild (DAISY group)
	var compat := GeneSystem.compute_compatibility("rose_gallica", "daisy_wild")
	_assert(compat == GeneSystem.COMPAT_CROSS_GROUP,
		"different groups returns COMPAT_CROSS_GROUP (%d, got %d)" % [GeneSystem.COMPAT_CROSS_GROUP, compat])


func test_breed_returns_valid_result() -> void:
	var color_a := {"r": 210, "g": 80, "b": 100}
	var color_b := {"r": 240, "g": 180, "b": 190}
	var result: Dictionary = GeneSystem.breed("rose_gallica", "rose_canina", color_a, color_b)

	var has_type: bool = result.has("plant_type") and result.plant_type != ""
	var has_color: bool = result.has("color") and result.color is Dictionary
	var has_is_rare: bool = result.has("is_rare") and result.is_rare is bool
	var has_rare_type: bool = result.has("rare_type")
	_assert(has_type and has_color and has_is_rare and has_rare_type,
		"breed() returns dict with plant_type, color, is_rare, rare_type (keys: %s)" % [str(result.keys())])


func test_breed_color_in_range() -> void:
	# Run breed multiple times to check color bounds
	var all_valid := true
	for _i in range(20):
		var result: Dictionary = GeneSystem.breed(
			"rose_gallica", "rose_canina",
			{"r": 210, "g": 80, "b": 100},
			{"r": 240, "g": 180, "b": 190})
		var c: Dictionary = result.color
		if c.r < 0 or c.r > 255 or c.g < 0 or c.g > 255 or c.b < 0 or c.b > 255:
			all_valid = false
			break
	_assert(all_valid, "breed result colors are 0-255 across 20 samples")


func test_blend_color_incomplete_dominance() -> void:
	# Blend pure red (255,0,0) and white (255,255,255) with dominance 0.5
	# Expected: R≈255, G≈127±noise, B≈127±noise
	var red := {"r": 255, "g": 0, "b": 0}
	var white := {"r": 255, "g": 255, "b": 255}
	var all_between := true
	for _i in range(20):
		var result: Dictionary = GeneSystem.blend_color(red, white, 0.5)
		# R should be 255 ± noise (255*0.5 + 255*0.5 = 255)
		if result.r < 240 or result.r > 255:
			all_between = false
			break
		# G should be ~127.5 ± noise, between 0 and 255
		if result.g < 90 or result.g > 170:
			all_between = false
			break
		# B should be ~127.5 ± noise
		if result.b < 90 or result.b > 170:
			all_between = false
			break
	_assert(all_between, "blend of red+white produces intermediate color (±noise)")


func test_can_breed_across_groups_flower_succulent() -> void:
	var can: bool = GeneSystem.can_breed_across_groups(
		PlantData.BreedingGroup.ROSE,
		PlantData.BreedingGroup.SUCCULENT)
	_assert(not can, "flower × succulent cannot breed (got %s)" % str(can))


func test_can_breed_across_groups_succulent_cactus() -> void:
	var can: bool = GeneSystem.can_breed_across_groups(
		PlantData.BreedingGroup.SUCCULENT,
		PlantData.BreedingGroup.CACTUS)
	_assert(can, "succulent × cactus can breed (got %s)" % str(not can))


# ============================================================
# GameState Tests
# ============================================================

func test_initial_seeds() -> void:
	_assert(GameState.seed_inventory.size() == 9,
		"_ready() sets 9 starter seeds (got %d)" % GameState.seed_inventory.size())

	var expected_initial := [
		"rose_gallica", "rose_canina",
		"daisy_wild", "sunflower_wild",
		"tulip_wild", "lily_candidum",
		"orchid_wild",
		"succulent_echeveria",
		"cactus_barrel",
	]
	var all_present := true
	for seed in expected_initial:
		if not seed in GameState.seed_inventory:
			all_present = false
			break
	_assert(all_present, "all 9 initial seeds are present in seed_inventory")


func test_seed_pack_unlock_at_milestone() -> void:
	# Test that get_seed_packs_for_milestone returns correct packs
	var packs_at_5: Array = PlantData.get_seed_packs_for_milestone(5)
	_assert("temperate_garden" in packs_at_5,
		"milestone 5 unlocks temperate_garden (got: %s)" % str(packs_at_5))

	var packs_at_10: Array = PlantData.get_seed_packs_for_milestone(10)
	_assert("eastern_garden" in packs_at_10,
		"milestone 10 unlocks eastern_garden (got: %s)" % str(packs_at_10))

	# At milestone 5, should NOT unlock milestone 10 pack
	var packs_at_4: Array = PlantData.get_seed_packs_for_milestone(4)
	_assert(not "temperate_garden" in packs_at_4,
		"milestone 4 does NOT unlock temperate_garden")

	# Save/restore state to test actual unlock
	var saved_packs: Dictionary = GameState.unlocked_seed_packs.duplicate()
	var saved_enc: Dictionary = GameState.encyclopedia.duplicate()
	var saved_seeds: Array = GameState.seed_inventory.duplicate()

	# Simulate 5 discoveries to trigger first pack
	GameState.unlocked_seed_packs.clear()
	GameState.encyclopedia.clear()
	GameState.seed_inventory.clear()
	for i in range(5):
		GameState.encyclopedia["fake_%d" % i] = true
	GameState._check_seed_pack_unlock()
	var unlocked := GameState.unlocked_seed_packs.has("temperate_garden")
	_assert(unlocked, "unlocking temperate_garden at 5 discoveries")

	# Verify species were added to inventory
	var has_species := "foxglove" in GameState.seed_inventory
	_assert(has_species, "unlocked pack species added to seed_inventory")

	# Restore
	GameState.unlocked_seed_packs = saved_packs
	GameState.encyclopedia = saved_enc
	GameState.seed_inventory = saved_seeds


func test_serialization_roundtrip() -> void:
	# Save current state
	var original: Dictionary = GameState.to_dictionary()

	# Modify state
	var saved_enc_size: int = GameState.encyclopedia.size()
	GameState.seed_inventory.append("test_species_roundtrip")
	GameState.encyclopedia["test_species_roundtrip"] = true
	GameState.unlocked_seed_packs["test_pack"] = true

	# Serialize
	var data: Dictionary = GameState.to_dictionary()
	_assert(data.has("seed_inventory"), "to_dictionary has seed_inventory")
	_assert(data.has("encyclopedia"), "to_dictionary has encyclopedia")
	_assert(data.has("unlocked_seed_packs"), "to_dictionary has unlocked_seed_packs")
	_assert("test_species_roundtrip" in data.seed_inventory, "serialized seed_inventory includes test entry")
	_assert(data.encyclopedia.has("test_species_roundtrip"), "serialized encyclopedia includes test entry")
	_assert(data.unlocked_seed_packs.has("test_pack"), "serialized unlocked_seed_packs includes test entry")

	# Restore from original
	GameState.from_dictionary(original)
	_assert(not "test_species_roundtrip" in GameState.seed_inventory,
		"from_dictionary restores seed_inventory")
	_assert(GameState.encyclopedia.size() == saved_enc_size,
		"from_dictionary restores encyclopedia size (got %d, expected %d)" % [GameState.encyclopedia.size(), saved_enc_size])
	_assert(not GameState.unlocked_seed_packs.has("test_pack"),
		"from_dictionary restores unlocked_seed_packs")
