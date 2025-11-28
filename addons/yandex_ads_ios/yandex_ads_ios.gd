extends Node

class_name YandexAdsIOS

# Signals
signal banner_loaded
signal banner_failed_to_load(error_code)
signal rewarded_video_loaded
signal rewarded_video_failed_to_load(error_code)
signal rewarded(currency, amount)
signal rewarded_video_closed

# Properties
var banner_id: String = ""
var rewarded_id: String = ""
var banner_on_top: bool = true

var _is_rewarded_video_loaded: bool = false
var _is_available: bool = false
var _native_plugin = null

func _enter_tree():
    if OS.get_name() == "iOS":
        _is_available = true
        # Try to get native plugin interface
        if ClassDB.class_exists("YandexAdsPlugin"):
            _native_plugin = ClassDB.instantiate("YandexAdsPlugin")
            print("✅ Yandex iOS native plugin found")
        else:
            print("⚠️ Yandex iOS native plugin not found, using fallback")
        print("✅ Yandex iOS wrapper initialized")
    else:
        print("⚠️ Yandex iOS wrapper - not on iOS platform")

func init() -> bool:
    if not _is_available:
        return false
    
    print("🟡 [YANDEX-IOS] Calling native init...")
    
    # Call native init directly
    if _native_plugin and _native_plugin.has_method("init"):
        _native_plugin.init()
        print("✅ [YANDEX-IOS] Native init called via plugin")
    else:
        print("⚠️ [YANDEX-IOS] Native plugin not available, init skipped")
    
    return true

# Load ads
func load_banner() -> void:
    if not _is_available:
        return
    
    print("📊 [YANDEX-IOS] Loading Yandex banner: " + banner_id)
    
    if _native_plugin and _native_plugin.has_method("load_banner"):
        _native_plugin.load_banner(banner_id, banner_on_top)
        print("✅ [YANDEX-IOS] Native load_banner called")
    else:
        # Simulate success for testing
        await get_tree().create_timer(0.5).timeout
        print("⚠️ [YANDEX-IOS] Banner load simulated (native not available)")
        _on_banner_loaded()

func load_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("🎬 [YANDEX-IOS] Loading Yandex rewarded: " + rewarded_id)
    
    if _native_plugin and _native_plugin.has_method("load_rewarded"):
        _native_plugin.load_rewarded(rewarded_id)
        print("✅ [YANDEX-IOS] Native load_rewarded called")
    else:
        # Simulate success for testing
        await get_tree().create_timer(0.5).timeout
        print("⚠️ [YANDEX-IOS] Rewarded load simulated (native not available)")
        _on_rewarded_video_ad_loaded()

func is_rewarded_video_loaded() -> bool:
    return _is_rewarded_video_loaded

# Show/hide
func show_banner() -> void:
    if not _is_available:
        return
    
    print("👁️ [YANDEX-IOS] Showing banner")
    
    if _native_plugin and _native_plugin.has_method("show_banner"):
        _native_plugin.show_banner()
    else:
        print("⚠️ [YANDEX-IOS] Native show_banner not available")

func hide_banner() -> void:
    if not _is_available:
        return
    
    print("🙈 [YANDEX-IOS] Hiding banner")
    
    if _native_plugin and _native_plugin.has_method("hide_banner"):
        _native_plugin.hide_banner()
    else:
        print("⚠️ [YANDEX-IOS] Native hide_banner not available")

func show_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("▶️ [YANDEX-IOS] Showing rewarded")
    
    if _native_plugin and _native_plugin.has_method("show_rewarded"):
        _native_plugin.show_rewarded()
        _is_rewarded_video_loaded = false
    else:
        print("⚠️ [YANDEX-IOS] Native show_rewarded not available")

# Callbacks (will be called from native code)
func _on_banner_loaded() -> void:
    print("✅ Yandex banner loaded (iOS)")
    emit_signal("banner_loaded")

func _on_banner_failed_to_load(error_code: int) -> void:
    print("❌ Yandex banner failed (iOS): " + str(error_code))
    emit_signal("banner_failed_to_load", error_code)

func _on_rewarded_video_ad_loaded() -> void:
    print("✅ Yandex rewarded loaded (iOS)")
    _is_rewarded_video_loaded = true
    emit_signal("rewarded_video_loaded")

func _on_rewarded_video_ad_failed_to_load(error_code: int) -> void:
    print("❌ Yandex rewarded failed (iOS): " + str(error_code))
    _is_rewarded_video_loaded = false
    emit_signal("rewarded_video_failed_to_load", error_code)

func _on_rewarded(currency: String, amount: int) -> void:
    print("🎉 Yandex reward (iOS): " + str(amount) + " " + currency)
    emit_signal("rewarded", currency, amount)

func _on_rewarded_video_ad_dismissed() -> void:
    print("🔚 Yandex rewarded closed (iOS)")
    emit_signal("rewarded_video_closed")
    # Reload
    load_rewarded_video()
