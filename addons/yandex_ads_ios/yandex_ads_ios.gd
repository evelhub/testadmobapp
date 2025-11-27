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

func _enter_tree():
    if OS.get_name() == "iOS":
        _is_available = true
        print("✅ Yandex iOS wrapper initialized")
    else:
        print("⚠️ Yandex iOS wrapper - not on iOS platform")

func init() -> bool:
    if not _is_available:
        return false
    
    # C function will be called automatically on iOS plugin load
    print("🟡 Yandex iOS init called")
    return true

# Load ads
func load_banner() -> void:
    if not _is_available:
        return
    
    print("📊 [YANDEX-IOS] Loading Yandex banner: " + banner_id)
    print("📊 [YANDEX-IOS] Banner on top: " + str(banner_on_top))
    
    # Simulate success for testing (native calls will be added later)
    await get_tree().create_timer(0.5).timeout
    print("✅ [YANDEX-IOS] Banner load simulated (native SDK not connected yet)")
    _on_banner_loaded()

func load_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("🎬 [YANDEX-IOS] Loading Yandex rewarded: " + rewarded_id)
    
    # Simulate success for testing
    await get_tree().create_timer(0.5).timeout
    print("✅ [YANDEX-IOS] Rewarded load simulated (native SDK not connected yet)")
    _on_rewarded_video_ad_loaded()

func is_rewarded_video_loaded() -> bool:
    return _is_rewarded_video_loaded

# Show/hide
func show_banner() -> void:
    if not _is_available:
        return
    
    if Engine.has_singleton("YandexAdsPlugin"):
        var plugin = Engine.get_singleton("YandexAdsPlugin")
        plugin.call("show_banner")

func hide_banner() -> void:
    if not _is_available:
        return
    
    if Engine.has_singleton("YandexAdsPlugin"):
        var plugin = Engine.get_singleton("YandexAdsPlugin")
        plugin.call("hide_banner")

func show_rewarded_video() -> void:
    if not _is_available:
        return
    
    print("▶️ Showing Yandex rewarded (iOS)")
    
    if Engine.has_singleton("YandexAdsPlugin"):
        var plugin = Engine.get_singleton("YandexAdsPlugin")
        plugin.call("show_rewarded")
    
    _is_rewarded_video_loaded = false

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
