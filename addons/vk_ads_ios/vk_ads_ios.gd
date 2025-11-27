extends Node

class_name VkAdsIOS

# Signals (same as Android version)
signal banner_loaded
signal banner_failed_to_load(error_code)
signal rewarded_video_loaded
signal rewarded_video_failed_to_load(error_code)
signal rewarded(type)
signal rewarded_video_closed

# Properties
var banner_id: int = 0
var rewarded_id: int = 0
var banner_on_top: bool = false

# Native singleton
var _native_singleton = null
var _is_rewarded_video_loaded: bool = false

func _enter_tree():
    if not init():
        print("⚠️ VK iOS singleton not found. iOS native plugin required.")

func init() -> bool:
    if Engine.has_singleton("VkAdsIOS"):
        _native_singleton = Engine.get_singleton("VkAdsIOS")
        print("✅ VK iOS singleton found")
        _connect_signals()
        return true
    return false

func _connect_signals():
    if _native_singleton:
        _native_singleton.banner_loaded.connect(_on_banner_loaded)
        _native_singleton.banner_failed.connect(_on_banner_failed_to_load)
        _native_singleton.rewarded_loaded.connect(_on_rewarded_video_ad_loaded)
        _native_singleton.rewarded_failed.connect(_on_rewarded_video_ad_failed_to_load)
        _native_singleton.rewarded_earned.connect(_on_rewarded)
        _native_singleton.rewarded_closed.connect(_on_rewarded_video_ad_dismissed)

# Load ads
func load_banner() -> void:
    if _native_singleton:
        print("📊 Loading VK banner: " + str(banner_id))
        _native_singleton.load_banner(banner_id, banner_on_top)

func load_rewarded_video() -> void:
    if _native_singleton:
        print("🎬 Loading VK rewarded: " + str(rewarded_id))
        _native_singleton.load_rewarded(rewarded_id)

func is_rewarded_video_loaded() -> bool:
    return _is_rewarded_video_loaded

# Show/hide
func show_banner() -> void:
    if _native_singleton:
        _native_singleton.show_banner()

func hide_banner() -> void:
    if _native_singleton:
        _native_singleton.hide_banner()

func show_rewarded_video() -> void:
    if _native_singleton:
        print("▶️ Showing VK rewarded")
        _native_singleton.show_rewarded()
        _is_rewarded_video_loaded = false

# Callbacks
func _on_banner_loaded() -> void:
    print("✅ VK banner loaded")
    emit_signal("banner_loaded")

func _on_banner_failed_to_load(error_code: int) -> void:
    print("❌ VK banner failed: " + str(error_code))
    emit_signal("banner_failed_to_load", error_code)

func _on_rewarded_video_ad_loaded() -> void:
    print("✅ VK rewarded loaded")
    _is_rewarded_video_loaded = true
    emit_signal("rewarded_video_loaded")

func _on_rewarded_video_ad_failed_to_load(error_code: int) -> void:
    print("❌ VK rewarded failed: " + str(error_code))
    _is_rewarded_video_loaded = false
    emit_signal("rewarded_video_failed_to_load", error_code)

func _on_rewarded(type: String) -> void:
    print("🎉 VK reward: " + type)
    emit_signal("rewarded", type)

func _on_rewarded_video_ad_dismissed() -> void:
    print("🔚 VK rewarded closed")
    emit_signal("rewarded_video_closed")
