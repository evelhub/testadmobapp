#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MyTargetSDK/MyTargetSDK.h>

#ifdef __cplusplus
extern "C" {
#endif

// Forward declarations
void vk_ads_init();
void vk_ads_deinit();
void vk_ads_load_banner(int slot_id, bool on_top);
void vk_ads_show_banner();
void vk_ads_hide_banner();
void vk_ads_load_rewarded(int slot_id);
void vk_ads_show_rewarded();
bool vk_ads_is_initialized();

#ifdef __cplusplus
}
#endif

// Global variables
static MTRGAdView *g_bannerView = nil;
static MTRGRewardedAd *g_rewardedAd = nil;
static bool g_isInitialized = false;
static int g_currentRewardedSlotID = 0;

// Callbacks to Godot
typedef void (*BannerLoadedCallback)();
typedef void (*BannerFailedCallback)(int error_code);
typedef void (*RewardedLoadedCallback)();
typedef void (*RewardedFailedCallback)(int error_code);
typedef void (*RewardedEarnedCallback)(const char* type);
typedef void (*RewardedClosedCallback)();

static BannerLoadedCallback g_banner_loaded_callback = nullptr;
static BannerFailedCallback g_banner_failed_callback = nullptr;
static RewardedLoadedCallback g_rewarded_loaded_callback = nullptr;
static RewardedFailedCallback g_rewarded_failed_callback = nullptr;
static RewardedEarnedCallback g_rewarded_earned_callback = nullptr;
static RewardedClosedCallback g_rewarded_closed_callback = nullptr;

// Banner Delegate
@interface VkBannerDelegate : NSObject <MTRGAdViewDelegate>
@end

@implementation VkBannerDelegate

- (void)onLoadWithAdView:(MTRGAdView *)adView {
    NSLog(@"✅ VK banner loaded");
    if (g_banner_loaded_callback) {
        g_banner_loaded_callback();
    }
}

- (void)onNoAdWithReason:(NSString *)reason adView:(MTRGAdView *)adView {
    NSLog(@"❌ VK banner failed: %@", reason);
    if (g_banner_failed_callback) {
        g_banner_failed_callback(1);
    }
}

@end

static VkBannerDelegate *g_bannerDelegate = nil;

// Rewarded Delegate
@interface VkRewardedDelegate : NSObject <MTRGRewardedAdDelegate>
@end

@implementation VkRewardedDelegate

- (void)onLoadWithRewardedAd:(MTRGRewardedAd *)rewardedAd {
    NSLog(@"✅ VK rewarded loaded");
    if (g_rewarded_loaded_callback) {
        g_rewarded_loaded_callback();
    }
}

- (void)onNoAdWithReason:(NSString *)reason rewardedAd:(MTRGRewardedAd *)rewardedAd {
    NSLog(@"❌ VK rewarded failed: %@", reason);
    if (g_rewarded_failed_callback) {
        g_rewarded_failed_callback(1);
    }
}

- (void)onReward:(MTRGReward *)reward rewardedAd:(MTRGRewardedAd *)rewardedAd {
    NSLog(@"🎉 VK reward earned: %@", reward.type);
    if (g_rewarded_earned_callback) {
        const char* type = [reward.type UTF8String];
        g_rewarded_earned_callback(type);
    }
}

- (void)onCloseWithRewardedAd:(MTRGRewardedAd *)rewardedAd {
    NSLog(@"🔚 VK rewarded closed");
    if (g_rewarded_closed_callback) {
        g_rewarded_closed_callback();
    }
    // Reload for next time
    if (g_currentRewardedSlotID > 0) {
        vk_ads_load_rewarded(g_currentRewardedSlotID);
    }
}

@end

static VkRewardedDelegate *g_rewardedDelegate = nil;

// Implementation
void vk_ads_init() {
    NSLog(@"🔵 Initializing VK Ads (MyTarget) SDK...");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MTRGManager setDebugMode:YES];
        [MTRGPrivacy setUserConsent:YES];
        
        g_isInitialized = true;
        g_bannerDelegate = [[VkBannerDelegate alloc] init];
        g_rewardedDelegate = [[VkRewardedDelegate alloc] init];
        
        NSLog(@"✅ VK Ads SDK initialized");
    });
}

void vk_ads_deinit() {
    NSLog(@"🔵 Deinitializing VK Ads...");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_bannerView) {
            [g_bannerView removeFromSuperview];
            g_bannerView = nil;
        }
        g_rewardedAd = nil;
        g_bannerDelegate = nil;
        g_rewardedDelegate = nil;
    });
}

void vk_ads_load_banner(int slot_id, bool on_top) {
    if (!g_isInitialized) {
        NSLog(@"❌ VK SDK not initialized yet");
        if (g_banner_failed_callback) {
            g_banner_failed_callback(1);
        }
        return;
    }
    
    NSLog(@"📊 Loading VK banner: %d", slot_id);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Create banner
        g_bannerView = [MTRGAdView adViewWithSlotId:slot_id];
        g_bannerView.delegate = g_bannerDelegate;
        g_bannerView.viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        // Load ad
        [g_bannerView load];
    });
}

void vk_ads_show_banner() {
    if (!g_bannerView) {
        NSLog(@"❌ Banner not loaded");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC && rootVC.view) {
            [rootVC.view addSubview:g_bannerView];
            
            // Position at bottom
            g_bannerView.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[
                [g_bannerView.bottomAnchor constraintEqualToAnchor:rootVC.view.safeAreaLayoutGuide.bottomAnchor],
                [g_bannerView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor],
                [g_bannerView.widthAnchor constraintEqualToConstant:320],
                [g_bannerView.heightAnchor constraintEqualToConstant:50]
            ]];
            
            NSLog(@"✅ VK banner shown");
        }
    });
}

void vk_ads_hide_banner() {
    if (!g_bannerView) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [g_bannerView removeFromSuperview];
        NSLog(@"✅ VK banner hidden");
    });
}

void vk_ads_load_rewarded(int slot_id) {
    if (!g_isInitialized) {
        NSLog(@"❌ VK SDK not initialized yet");
        if (g_rewarded_failed_callback) {
            g_rewarded_failed_callback(1);
        }
        return;
    }
    
    g_currentRewardedSlotID = slot_id;
    NSLog(@"🎬 Loading VK rewarded: %d", slot_id);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        g_rewardedAd = [MTRGRewardedAd rewardedAdWithSlotId:slot_id];
        g_rewardedAd.delegate = g_rewardedDelegate;
        [g_rewardedAd load];
    });
}

void vk_ads_show_rewarded() {
    if (!g_rewardedAd) {
        NSLog(@"❌ Rewarded ad not loaded");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            [g_rewardedAd showWithController:rootVC];
            NSLog(@"▶️ Showing VK rewarded");
        }
    });
}

bool vk_ads_is_initialized() {
    return g_isInitialized;
}

// Callback setters
#ifdef __cplusplus
extern "C" {
#endif

void vk_ads_set_banner_loaded_callback(BannerLoadedCallback callback) {
    g_banner_loaded_callback = callback;
}

void vk_ads_set_banner_failed_callback(BannerFailedCallback callback) {
    g_banner_failed_callback = callback;
}

void vk_ads_set_rewarded_loaded_callback(RewardedLoadedCallback callback) {
    g_rewarded_loaded_callback = callback;
}

void vk_ads_set_rewarded_failed_callback(RewardedFailedCallback callback) {
    g_rewarded_failed_callback = callback;
}

void vk_ads_set_rewarded_earned_callback(RewardedEarnedCallback callback) {
    g_rewarded_earned_callback = callback;
}

void vk_ads_set_rewarded_closed_callback(RewardedClosedCallback callback) {
    g_rewarded_closed_callback = callback;
}

#ifdef __cplusplus
}
#endif
