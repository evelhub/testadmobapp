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
var _native_plugin = null

func _enter_tree():
    if OS.get_name() == "iOS":
        _is_available = true
        # Try to get native plugin interface
        if ClassDB.class_exists("VkAdsPlugin"):
            _native_plugin = ClassDB.instantiate("VkAdsPlugin")
            print("✅ VK iOS native plugin found")
        else:
            print("⚠️ VK iOS native plugin not found, using fallback")
        print("✅ VK iOS wrapper initialized")
    else:
        print("⚠️ VK iOS wrapper - not on iOS platform")

func init() -> bool:
    if not _is_available:
        return false
    
    print("🔵 [VK-IOS] Calling native init...")
    
    # Call native init directly
    if _native_plugin and _native_plugin.has_method("init"):
        _native_plugin.init()
        print("✅ [VK-IOS] Native init called via plugin")
    else:
        print("⚠️ [VK-IOS] Native plugin not available, init skipped")
    
    return true

# Load ads
func load_banner() -> void:
    if not _is_available:
        return
    
    print("📊 [VK-IOS] Loading VK banner: " + str(banner_id))
    
    if _native_plugin and _native_plugin.has_method("load_banner"):
        _native_plugin.load_banner(banner_id, banner_on_top)
        print("✅ [VK-IOS] Native load_banner called")
    else:
        # Simulate success
        await get_tree().create_timer(0.5).timeout
        print("⚠️ [VK-IOS] Banner load simulated (native not available)")
        _on_banner_loaded()

func load_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("🎬 [VK-IOS] Loading VK rewarded: " + str(rewarded_id))
    
    if _native_plugin and _native_plugin.has_method("load_rewarded"):
        _native_plugin.load_rewarded(rewarded_id)
        print("✅ [VK-IOS] Native load_rewarded called")
    else:
        # Simulate success
        await get_tree().create_timer(0.5).timeout
        print("⚠️ [VK-IOS] Rewarded load simulated (native not available)")
        _on_rewarded_video_ad_loaded()

func is_rewarded_video_loaded() -> bool:
    return _is_rewarded_video_loaded

# Show/hide
func show_banner() -> void:
    if not _is_available:
        return
    
    print("👁️ [VK-IOS] Showing banner")
    
    if _native_plugin and _native_plugin.has_method("show_banner"):
        _native_plugin.show_banner()
    else:
        print("⚠️ [VK-IOS] Native show_banner not available")

func hide_banner() -> void:
    if not _is_available:
        return
    
    print("🙈 [VK-IOS] Hiding banner")
    
    if _native_plugin and _native_plugin.has_method("hide_banner"):
        _native_plugin.hide_banner()
    else:
        print("⚠️ [VK-IOS] Native hide_banner not available")

func show_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("▶️ [VK-IOS] Showing rewarded")
    
    if _native_plugin and _native_plugin.has_method("show_rewarded"):
        _native_plugin.show_rewarded()
        _is_rewarded_video_loaded = false
    else:
        print("⚠️ [VK-IOS] Native show_rewarded not available")

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
