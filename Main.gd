extends Control

# UI References
@onready var yandex_button: Button = $ScrollContainer/VBoxContainer/YandexButton
@onready var vk_button: Button = $ScrollContainer/VBoxContainer/VKButton
@onready var admob_button: Button = $ScrollContainer/VBoxContainer/AdMobButton
@onready var status_label: Label = $ScrollContainer/VBoxContainer/StatusLabel

# Ad Networks (no type hints - will be set dynamically based on platform)
var yandex_ads
var vk_ads
var admob_rewarded_ad: RewardedAd
var admob_rewarded_callback: RewardedAdLoadCallback

# Platform detection
var is_android: bool = OS.get_name() == "Android"
var is_ios: bool = OS.get_name() == "iOS"

func _ready():
	print("=== Multi-Ad Test App Started ===")
	print("Platform: " + OS.get_name())
	update_status("Starting on " + OS.get_name() + "...")
	
	# Connect buttons
	yandex_button.pressed.connect(_on_yandex_button_pressed)
	vk_button.pressed.connect(_on_vk_button_pressed)
	admob_button.pressed.connect(_on_admob_button_pressed)
	
	# Wait a bit
	await get_tree().create_timer(1.0).timeout
	
	# Initialize ad networks based on platform
	if is_android:
		_init_android_ads()
	elif is_ios:
		_init_ios_ads()
	else:
		update_status("Desktop - ads disabled")
		print("⚠️ Running on desktop, ads disabled")

# ============================================
# ANDROID INITIALIZATION
# ============================================
func _init_android_ads():
	print("📱 Initializing Android ads...")
	update_status("Initializing Android ads...")
	
	# Initialize Yandex Ads
	_init_yandex_android()
	
	# Initialize VK Ads
	_init_vk_android()
	
	# Initialize AdMob (for testing)
	_init_admob()
	
	update_status("Android ads ready!")

func _init_yandex_android():
	print("🟡 Initializing Yandex Ads (Android)...")
	
	yandex_ads = YandexAds.new()
	add_child(yandex_ads)
	
	# Set test IDs
	yandex_ads.banner_id = "demo-banner-yandex"
	yandex_ads.rewarded_id = "demo-rewarded-yandex"
	yandex_ads.banner_on_top = true
	yandex_ads.banner_width = 320
	yandex_ads.banner_height = 50
	
	# Connect signals
	yandex_ads.banner_loaded.connect(_on_yandex_banner_loaded)
	yandex_ads.banner_failed_to_load.connect(_on_yandex_banner_failed)
	yandex_ads.rewarded_video_loaded.connect(_on_yandex_rewarded_loaded)
	yandex_ads.rewarded_video_failed_to_load.connect(_on_yandex_rewarded_failed)
	yandex_ads.rewarded.connect(_on_yandex_rewarded_earned)
	
	# Load banners
	yandex_ads.load_banner()
	yandex_ads.show_banner()
	
	# Load rewarded
	yandex_ads.load_rewarded_video()
	
	print("✅ Yandex Ads initialized")

func _init_vk_android():
	print("🔵 Initializing VK Ads (Android)...")
	
	vk_ads = VkAds.new()
	add_child(vk_ads)
	
	# Set test IDs
	vk_ads.banner_id = 44987  # Demo banner slot
	vk_ads.rewarded_id = 44988  # Demo rewarded slot
	vk_ads.banner_on_top = false  # Bottom banner
	
	# Connect signals
	vk_ads.banner_loaded.connect(_on_vk_banner_loaded)
	vk_ads.banner_failed_to_load.connect(_on_vk_banner_failed)
	vk_ads.rewarded_video_loaded.connect(_on_vk_rewarded_loaded)
	vk_ads.rewarded_video_failed_to_load.connect(_on_vk_rewarded_failed)
	vk_ads.rewarded.connect(_on_vk_rewarded_earned)
	
	# Load banners
	vk_ads.load_banner()
	vk_ads.show_banner()
	
	# Load rewarded
	vk_ads.load_rewarded_video()
	
	print("✅ VK Ads initialized")

# ============================================
# iOS INITIALIZATION
# ============================================
func _init_ios_ads():
	print("📱 Initializing iOS ads...")
	update_status("Initializing iOS ads...")
	
	# Initialize Yandex Ads (iOS)
	_init_yandex_ios()
	
	# Initialize VK Ads (iOS)
	_init_vk_ios()
	
	# Initialize AdMob (for testing)
	_init_admob()
	
	update_status("iOS ads ready!")

func _init_yandex_ios():
	print("🟡 Initializing Yandex Ads (iOS)...")
	update_status("Loading Yandex iOS class...")
	
	var YandexAdsIOSClass = load("res://addons/yandex_ads_ios/yandex_ads_ios.gd")
	if YandexAdsIOSClass:
		update_status("Yandex class loaded! Creating instance...")
		yandex_ads = YandexAdsIOSClass.new()
		add_child(yandex_ads)
		update_status("Yandex instance created!")
		
		# Set test IDs
		yandex_ads.banner_id = "demo-banner-yandex"
		yandex_ads.rewarded_id = "demo-rewarded-yandex"
		yandex_ads.banner_on_top = true
		
		# Connect signals
		yandex_ads.banner_loaded.connect(_on_yandex_banner_loaded)
		yandex_ads.banner_failed_to_load.connect(_on_yandex_banner_failed)
		yandex_ads.rewarded_video_loaded.connect(_on_yandex_rewarded_loaded)
		yandex_ads.rewarded_video_failed_to_load.connect(_on_yandex_rewarded_failed)
		yandex_ads.rewarded.connect(_on_yandex_rewarded_earned)
		
		# Load banners
		update_status("Loading Yandex banner...")
		yandex_ads.load_banner()
		yandex_ads.show_banner()
		
		# Load rewarded
		update_status("Loading Yandex rewarded...")
		yandex_ads.load_rewarded_video()
		
		print("✅ Yandex Ads (iOS) initialized")
		update_status("✅ Yandex iOS ready!")
	else:
		print("❌ Yandex iOS class not found")
		update_status("❌ Yandex class NOT FOUND!")
		yandex_button.disabled = true

func _init_vk_ios():
	print("🔵 Initializing VK Ads (iOS)...")
	
	var VkAdsIOSClass = load("res://addons/vk_ads_ios/vk_ads_ios.gd")
	if VkAdsIOSClass:
		vk_ads = VkAdsIOSClass.new()
		add_child(vk_ads)
		
		# Set test IDs
		vk_ads.banner_id = 44987  # Demo banner slot
		vk_ads.rewarded_id = 44988  # Demo rewarded slot
		vk_ads.banner_on_top = false  # Bottom banner
		
		# Connect signals
		vk_ads.banner_loaded.connect(_on_vk_banner_loaded)
		vk_ads.banner_failed_to_load.connect(_on_vk_banner_failed)
		vk_ads.rewarded_video_loaded.connect(_on_vk_rewarded_loaded)
		vk_ads.rewarded_video_failed_to_load.connect(_on_vk_rewarded_failed)
		vk_ads.rewarded.connect(_on_vk_rewarded_earned)
		
		# Load banners
		vk_ads.load_banner()
		vk_ads.show_banner()
		
		# Load rewarded
		vk_ads.load_rewarded_video()
		
		print("✅ VK Ads (iOS) initialized")
	else:
		print("❌ VK iOS class not found")
		vk_button.disabled = true

# ============================================
# ADMOB INITIALIZATION (iOS + Android)
# ============================================
func _init_admob():
	print("🟢 Initializing AdMob...")
	
	admob_rewarded_callback = RewardedAdLoadCallback.new()
	admob_rewarded_callback.on_ad_failed_to_load = func(error: LoadAdError):
		print("❌ AdMob rewarded failed: " + error.message)
	admob_rewarded_callback.on_ad_loaded = func(ad: RewardedAd):
		admob_rewarded_ad = ad
		admob_rewarded_ad.on_user_earned_reward = _on_admob_rewarded_earned
		print("✅ AdMob rewarded loaded")
	
	MobileAds.initialize()
	await get_tree().create_timer(2.0).timeout
	
	# Load rewarded
	var rewarded_id = "ca-app-pub-3940256099942544/1712485313"
	RewardedAdLoader.new().load(rewarded_id, AdRequest.new(), admob_rewarded_callback)
	
	print("✅ AdMob initialized")

# ============================================
# BUTTON HANDLERS
# ============================================
func _on_yandex_button_pressed():
	print("🎬 Yandex button pressed")
	if yandex_ads and yandex_ads.is_rewarded_video_loaded():
		print("  Showing Yandex rewarded...")
		yandex_ads.show_rewarded_video()
		update_status("Showing Yandex ad...")
	else:
		print("  ❌ Yandex rewarded not loaded")
		update_status("Yandex ad not ready")
		# Reload
		if yandex_ads:
			yandex_ads.load_rewarded_video()

func _on_vk_button_pressed():
	print("🎬 VK button pressed")
	if vk_ads and vk_ads.is_rewarded_video_loaded():
		print("  Showing VK rewarded...")
		vk_ads.show_rewarded_video()
		update_status("Showing VK ad...")
	else:
		print("  ❌ VK rewarded not loaded")
		update_status("VK ad not ready")
		# Reload
		if vk_ads:
			vk_ads.load_rewarded_video()

func _on_admob_button_pressed():
	print("🎬 AdMob button pressed")
	if admob_rewarded_ad:
		print("  Showing AdMob rewarded...")
		admob_rewarded_ad.show()
		update_status("Showing AdMob ad...")
	else:
		print("  ❌ AdMob rewarded not loaded")
		update_status("AdMob ad not ready")

# ============================================
# YANDEX CALLBACKS
# ============================================
func _on_yandex_banner_loaded():
	print("✅ Yandex banner loaded")
	update_status("Yandex banner visible")

func _on_yandex_banner_failed(error_code: int):
	print("❌ Yandex banner failed: " + str(error_code))
	update_status("Yandex banner failed: " + str(error_code))

func _on_yandex_rewarded_loaded():
	print("✅ Yandex rewarded loaded")
	update_status("Yandex rewarded ready!")

func _on_yandex_rewarded_failed(error_code: int):
	print("❌ Yandex rewarded failed: " + str(error_code))
	update_status("Yandex rewarded failed: " + str(error_code))

func _on_yandex_rewarded_earned(currency: String, amount: int):
	print("🎉 Yandex reward: " + str(amount) + " " + currency)
	update_status("Yandex reward: " + str(amount) + " " + currency)
	# Reload for next time
	yandex_ads.load_rewarded_video()

# ============================================
# VK CALLBACKS
# ============================================
func _on_vk_banner_loaded():
	print("✅ VK banner loaded")
	update_status("VK banner visible")

func _on_vk_banner_failed(error_code: int):
	print("❌ VK banner failed: " + str(error_code))
	update_status("VK banner failed: " + str(error_code))

func _on_vk_rewarded_loaded():
	print("✅ VK rewarded loaded")
	update_status("VK rewarded ready!")

func _on_vk_rewarded_failed(error_code: int):
	print("❌ VK rewarded failed: " + str(error_code))
	update_status("VK rewarded failed: " + str(error_code))

func _on_vk_rewarded_earned(type: String):
	print("🎉 VK reward: " + type)
	update_status("VK reward earned!")
	# Reload for next time
	vk_ads.load_rewarded_video()

# ============================================
# ADMOB CALLBACKS
# ============================================
func _on_admob_rewarded_earned(reward: RewardedItem):
	print("🎉 AdMob reward: " + str(reward.amount) + " " + reward.type)
	update_status("AdMob reward: " + str(reward.amount))

# ============================================
# UTILITY
# ============================================
func update_status(text: String):
	status_label.text = text
	print("📝 Status: " + text)
