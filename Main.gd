extends Control

@onready var watch_button: Button = $CenterContainer/VBoxContainer/Button
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel

var top_banner: AdView
var bottom_banner: AdView
var rewarded_ad: RewardedAd
var rewarded_load_callback: RewardedAdLoadCallback = RewardedAdLoadCallback.new()

func _ready():
	print("=== AdMob Test App Started ===")
	update_status("Starting...")
	
	# Setup rewarded callbacks
	rewarded_load_callback.on_ad_failed_to_load = func(ad_error: LoadAdError): 
		print("❌ Rewarded fail: " + ad_error.message)
		update_status("Rewarded failed: " + ad_error.message)
	
	rewarded_load_callback.on_ad_loaded = func(loaded_ad: RewardedAd): 
		rewarded_ad = loaded_ad
		rewarded_ad.on_user_earned_reward = _on_rewarded_earned
		print("✅ Rewarded loaded!")
		update_status("Rewarded ad ready!")
	
	# Connect button
	watch_button.pressed.connect(_on_watch_pressed)
	
	# Wait a bit
	await get_tree().create_timer(1.0).timeout
	update_status("Initializing AdMob...")
	
	# Initialize AdMob
	print("📱 Initializing MobileAds...")
	MobileAds.initialize()
	await get_tree().create_timer(2.0).timeout
	print("✅ MobileAds initialized")
	
	# Load banners
	update_status("Loading banners...")
	_load_banners()
	
	# Load rewarded
	update_status("Loading rewarded ad...")
	_load_rewarded()

func _load_banners():
	print("📊 Loading banners...")
	var banner_id = "ca-app-pub-3940256099942544/2934735716"
	var ad_size = AdSize.get_current_orientation_anchored_adaptive_banner_ad_size(AdSize.FULL_WIDTH)
	
	# Top banner
	print("  Creating top banner...")
	top_banner = AdView.new(banner_id, ad_size, AdPosition.Values.TOP)
	var ad_listener_top = AdListener.new()
	ad_listener_top.on_ad_loaded = func(): print("✅ Top banner loaded")
	ad_listener_top.on_ad_failed_to_load = func(error: LoadAdError): print("❌ Top banner failed: " + error.message)
	top_banner.ad_listener = ad_listener_top
	top_banner.load_ad(AdRequest.new())
	
	# Bottom banner
	print("  Creating bottom banner...")
	bottom_banner = AdView.new(banner_id, ad_size, AdPosition.Values.BOTTOM)
	var ad_listener_bottom = AdListener.new()
	ad_listener_bottom.on_ad_loaded = func(): print("✅ Bottom banner loaded")
	ad_listener_bottom.on_ad_failed_to_load = func(error: LoadAdError): print("❌ Bottom banner failed: " + error.message)
	bottom_banner.ad_listener = ad_listener_bottom
	bottom_banner.load_ad(AdRequest.new())

func _load_rewarded():
	print("🎬 Loading rewarded ad...")
	var rewarded_id = "ca-app-pub-3940256099942544/1712485313"
	RewardedAdLoader.new().load(rewarded_id, AdRequest.new(), rewarded_load_callback)

func _on_watch_pressed():
	print("🎬 Watch button pressed")
	if rewarded_ad:
		print("  Showing rewarded ad...")
		rewarded_ad.show()
		update_status("Showing ad...")
	else:
		print("  ❌ Rewarded not loaded yet")
		update_status("Ad not ready, wait...")

func _on_rewarded_earned(reward: RewardedItem):
	print("🎉 Reward earned: " + str(reward.amount) + " " + reward.type)
	update_status("Reward: " + str(reward.amount) + " " + reward.type)

func update_status(text: String):
	status_label.text = text
	print("📝 Status: " + text)
