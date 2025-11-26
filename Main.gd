extends Node2D

@onready var watch_button: Button = $Button

var top_banner: AdView
var bottom_banner: AdView
var rewarded_ad: RewardedAd
var rewarded_load_callback: RewardedAdLoadCallback = RewardedAdLoadCallback.new()

func _ready():
	rewarded_load_callback.on_ad_failed_to_load = func(ad_error: LoadAdError): print("Rewarded fail: " + ad_error.message)
	rewarded_load_callback.on_ad_loaded = func(loaded_ad: RewardedAd): 
		rewarded_ad = loaded_ad
		rewarded_ad.on_user_earned_reward = _on_rewarded_earned
		print("Rewarded loaded!")
	
	# Consent (popup from .gdip debug)
	await get_tree().create_timer(1.0).timeout  # Delay
	
	# Init
	MobileAds.initialize()
	await get_tree().create_timer(2.0).timeout
	
	# Banners (test ID)
	var banner_id = "ca-app-pub-3940256099942544/2934735716"
	var ad_size = AdSize.get_current_orientation_anchored_adaptive_banner_ad_size(AdSize.FULL_WIDTH)
	
	top_banner = AdView.new(banner_id, ad_size, AdPosition.Values.TOP)
	top_banner.load_ad(AdRequest.new())
	
	bottom_banner = AdView.new(banner_id, ad_size, AdPosition.Values.BOTTOM)
	bottom_banner.load_ad(AdRequest.new())
	
	# Rewarded (test ID, mediation fallback)
	var rewarded_id = "ca-app-pub-3940256099942544/1712485313"
	RewardedAdLoader.new().load(rewarded_id, AdRequest.new(), rewarded_load_callback)
	
	watch_button.pressed.connect(_on_watch_pressed)

func _on_watch_pressed():
	if rewarded_ad:
		rewarded_ad.show()
	else:
		print("Rewarded not loaded — wait/VPN")

func _on_rewarded_earned(reward: RewardedItem):
	print("Reward: " + str(reward.amount) + " " + reward.type)
