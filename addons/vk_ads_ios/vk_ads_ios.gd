extends Node

class_name VkAdsIOS

# Signals
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

var _is_rewarded_video_loaded: bool = false
var _is_available: bool = false

func _enter_tree():
    if OS.get_name() == "iOS":
        _is_available = true
        print("✅ VK iOS wrapper initialized")
    else:
        print("⚠️ VK iOS wrapper - not on iOS platform")

func init() -> bool:
    if not _is_available:
        return false
    
    print("🔵 VK iOS init called")
    return true

# Load ads
func load_banner() -> void:
    if not _is_available:
        return
    
    print("📊 Loading VK banner (iOS): " + str(banner_id))
    
    if Engine.has_singleton("VkAdsPlugin"):
        var plugin = Engine.get_singleton("VkAdsPlugin")
        plugin.call("load_banner", banner_id, banner_on_top)
    else:
        # Simulate success
        await get_tree().create_timer(0.5).timeout
        _on_banner_loaded()

func load_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("🎬 Loading VK rewarded (iOS): " + str(rewarded_id))
    
    if Engine.has_singleton("VkAdsPlugin"):
        var plugin = Engine.get_singleton("VkAdsPlugin")
        plugin.call("load_rewarded", rewarded_id)
    else:
        # Simulate success
        await get_tree().create_timer(0.5).timeout
        _on_rewarded_video_ad_loaded()

func is_rewarded_video_loaded() -> bool:
    return _is_rewarded_video_loaded

# Show/hide
func show_banner() -> void:
    if not _is_available:
        return
    
    if Engine.has_singleton("VkAdsPlugin"):
        var plugin = Engine.get_singleton("VkAdsPlugin")
        plugin.call("show_banner")

func hide_banner() -> void:
    if not _is_available:
        return
    
    if Engine.has_singleton("VkAdsPlugin"):
        var plugin = Engine.get_singleton("VkAdsPlugin")
        plugin.call("hide_banner")

func show_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("▶️ Showing VK rewarded (iOS)")
    
    if Engine.has_singleton("VkAdsPlugin"):
        var plugin = Engine.get_singleton("VkAdsPlugin")
        plugin.call("show_rewarded")
    
    _is_rewarded_video_loaded = false

# Callbacks
func _on_banner_loaded() -> void:
    print("✅ VK banner loaded (iOS)")
    emit_signal("banner_loaded")

func _on_banner_failed_to_load(error_code: int) -> void:
    print("❌ VK banner failed (iOS): " + str(error_code))
    emit_signal("banner_failed_to_load", error_code)

func _on_rewarded_video_ad_loaded() -> void:
    print("✅ VK rewarded loaded (iOS)")
    _is_rewarded_video_loaded = true
    emit_signal("rewarded_video_loaded")

func _on_rewarded_video_ad_failed_to_load(error_code: int) -> void:
    print("❌ VK rewarded failed (iOS): " + str(error_code))
    _is_rewarded_video_loaded = false
    emit_signal("rewarded_video_failed_to_load", error_code)

func _on_rewarded(type: String) -> void:
    print("🎉 VK reward (iOS): " + type)
    emit_signal("rewarded", type)

func _on_rewarded_video_ad_dismissed() -> void:
    print("🔚 VK rewarded closed (iOS)")
    emit_signal("rewarded_video_closed")
    # Reload
    load_rewarded_video()
