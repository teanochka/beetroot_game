extends CanvasLayer

const DIALOGUE_SEQUENCE: DialogueSequence = preload("res://resources/tutorial_dialogues/tutorial_dialogue_sequence.tres")
const TYPEWRITER_CHARS_PER_SECOND: float = 55.0
const DIALOGUE_TRIGGER_DELAY: float = 5.0

@onready var image_view: Panel = $VBoxContainer/ImageView
@onready var dialogue_text_label: RichTextLabel = $VBoxContainer/Panel/MarginContainer/MainText
@onready var image_text_label: RichTextLabel = $VBoxContainer/ImageView/MarginContainer/TutorialVisual/ImageText
@onready var image_rect: TextureRect = $VBoxContainer/ImageView/MarginContainer/TutorialVisual/TextureRect
@onready var image_accept_button: Button = $VBoxContainer/ImageView/MarginContainer/TutorialVisual/Button

var dialogue_queue: Array[DialogueEntry] = []
var current_entry: DialogueEntry
var current_pages: Array[String] = []
var current_page_index: int = 0
var shown_triggers: Dictionary = {}
var pending_triggers: Dictionary = {}
var is_open: bool = false
var is_typing: bool = false
var is_changing_entry: bool = false
var typing_tween: Tween

func _ready() -> void:
	visible = false
	dialogue_text_label.scroll_active = false
	image_text_label.scroll_active = false
	image_accept_button.pressed.connect(advance)
	EventBus.current_task_changed.connect(_on_current_task_changed)
	
	await get_tree().process_frame
	enqueue_trigger("intro")
	enqueue_current_tutorial_task()

func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()
			advance()

func _on_current_task_changed(task_type: String) -> void:
	enqueue_trigger(task_type)

func enqueue_current_tutorial_task() -> void:
	var tutorial = get_tree().get_first_node_in_group("Tutorial")
	if tutorial and tutorial.current_task_type != "":
		enqueue_trigger(tutorial.current_task_type)

func enqueue_trigger(trigger: String) -> void:
	if trigger.is_empty() or shown_triggers.has(trigger) or pending_triggers.has(trigger):
		return
	
	var entries = get_entries_for_trigger(trigger)
	if entries.is_empty():
		return
	
	pending_triggers[trigger] = true
	await get_tree().create_timer(DIALOGUE_TRIGGER_DELAY).timeout
	pending_triggers.erase(trigger)
	if shown_triggers.has(trigger):
		return
	
	shown_triggers[trigger] = true
	for entry in entries:
		dialogue_queue.append(entry)
	
	if not is_open:
		open_dialogue()

func get_entries_for_trigger(trigger: String) -> Array[DialogueEntry]:
	var entries: Array[DialogueEntry] = []
	for entry in DIALOGUE_SEQUENCE.entries:
		if entry is DialogueEntry and entry.trigger == trigger:
			entries.append(entry)
	return entries

func open_dialogue() -> void:
	EventBus.is_dialogue_visible = true
	visible = true
	is_open = true
	is_changing_entry = true
	await show_next_entry()
	is_changing_entry = false

func close_dialogue() -> void:
	if typing_tween:
		typing_tween.kill()
		typing_tween = null
	
	visible = false
	is_open = false
	is_typing = false
	is_changing_entry = false
	current_entry = null
	current_pages.clear()
	current_page_index = 0
	EventBus.is_dialogue_visible = false

func advance() -> void:
	if not is_open:
		return
	
	if is_typing:
		finish_typewriter()
		return
	
	if current_page_index < current_pages.size() - 1:
		current_page_index += 1
		show_current_page()
		return
	
	if is_changing_entry:
		return
	
	is_changing_entry = true
	await show_next_entry()
	is_changing_entry = false

func show_next_entry() -> void:
	if dialogue_queue.is_empty():
		close_dialogue()
		return
	
	current_entry = dialogue_queue.pop_front()
	apply_entry_visuals(current_entry)
	await get_tree().process_frame
	var previous_text_modulate = dialogue_text_label.modulate
	dialogue_text_label.modulate.a = 0.0
	current_pages = await build_pages(current_entry.main_text)
	dialogue_text_label.modulate = previous_text_modulate
	current_page_index = 0
	show_current_page()

func apply_entry_visuals(entry: DialogueEntry) -> void:
	var has_image = entry.image != null
	var has_subtext = not entry.image_subtext.strip_edges().is_empty()
	image_view.visible = has_image or has_subtext
	image_rect.visible = has_image
	image_text_label.visible = has_subtext
	image_rect.texture = entry.image
	image_text_label.text = entry.image_subtext

func show_current_page() -> void:
	if current_pages.is_empty():
		dialogue_text_label.text = ""
	else:
		dialogue_text_label.text = current_pages[current_page_index]
	start_typewriter()

func start_typewriter() -> void:
	if typing_tween:
		typing_tween.kill()
	
	var total_characters = dialogue_text_label.get_total_character_count()
	dialogue_text_label.visible_characters = 0
	is_typing = total_characters > 0
	
	if not is_typing:
		return
	
	var duration = max(0.1, float(total_characters) / TYPEWRITER_CHARS_PER_SECOND)
	typing_tween = create_tween()
	typing_tween.tween_property(dialogue_text_label, "visible_characters", total_characters, duration)
	typing_tween.finished.connect(_on_typewriter_finished)

func _on_typewriter_finished() -> void:
	is_typing = false
	typing_tween = null

func finish_typewriter() -> void:
	if typing_tween:
		typing_tween.kill()
		typing_tween = null
	dialogue_text_label.visible_characters = dialogue_text_label.get_total_character_count()
	is_typing = false

func build_pages(text: String) -> Array[String]:
	var clean_text = text.strip_edges()
	if clean_text.is_empty():
		return [""]
	
	var pages: Array[String] = []
	var current_page = ""
	
	for sentence in split_sentences(clean_text):
		var candidate = append_text(current_page, sentence)
		var candidate_fits = await text_fits(candidate)
		if candidate_fits:
			current_page = candidate
			continue
		
		if not current_page.is_empty():
			pages.append(current_page)
		
		var sentence_fits = await text_fits(sentence)
		if sentence_fits:
			current_page = sentence
		else:
			var word_pages = await split_by_words(sentence)
			for i in range(word_pages.size()):
				if i == word_pages.size() - 1:
					current_page = word_pages[i]
				else:
					pages.append(word_pages[i])
	
	if not current_page.is_empty():
		pages.append(current_page)
	
	if pages.is_empty():
		pages.append(clean_text)
	
	return pages

func split_sentences(text: String) -> Array[String]:
	var sentences: Array[String] = []
	var current_sentence = ""
	var sentence_endings = [".", "!", "?", "\n"]
	
	for i in range(text.length()):
		var character = text.substr(i, 1)
		current_sentence += character
		if sentence_endings.has(character):
			var sentence = current_sentence.strip_edges()
			if not sentence.is_empty():
				sentences.append(sentence)
			current_sentence = ""
	
	var tail = current_sentence.strip_edges()
	if not tail.is_empty():
		sentences.append(tail)
	
	return sentences

func split_by_words(text: String) -> Array[String]:
	var pages: Array[String] = []
	var current_page = ""
	
	for word in text.split(" ", false):
		var candidate = append_text(current_page, word)
		var candidate_fits = await text_fits(candidate)
		if candidate_fits:
			current_page = candidate
			continue
		
		if not current_page.is_empty():
			pages.append(current_page)
		current_page = word
	
	if not current_page.is_empty():
		pages.append(current_page)
	
	return pages

func append_text(base_text: String, added_text: String) -> String:
	if base_text.is_empty():
		return added_text
	return base_text + " " + added_text

func text_fits(text: String) -> bool:
	dialogue_text_label.text = text
	dialogue_text_label.visible_characters = -1
	await get_tree().process_frame
	
	var available_height = dialogue_text_label.size.y
	if available_height <= 0.0:
		available_height = dialogue_text_label.get_parent().size.y
	
	return dialogue_text_label.get_content_height() <= available_height
