#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Forward declarations for Yandex SDK classes (avoid importing SDK during compilation)
@class YMABannerView;
@class YMARewardedAd;
@class YMAAdSize;
@class YMAAdRequestConfiguration;
@protocol YMAReward;

// Yandex SDK static methods (forward declarations)
@interface YMAMobileAds : NSObject
+ (void)enableLogging;
+ (void)initializeSDKWithCompletionHandler:(void (^)(void))completionHandler;
@end

@interface YMAAdSize : NSObject
+ (instancetype)stickyAdSizeWithContainerWidth:(CGFloat)width;
@end

@interface YMARewardedAd : NSObject
+ (void)loadWithRequestConfiguration:(YMAAdRequestConfiguration *)configuration
                    completionHandler:(void (^)(YMARewardedAd *ad, NSError *error))completionHandler;
- (void)showFromViewController:(UIViewController *)viewController;
@property (nonatomic, weak) id delegate;
@end

@interface YMAAdRequestConfiguration : NSObject
- (instancetype)initWithAdUnitID:(NSString *)adUnitID;
@end

@interface YMABannerView : UIView
- (instancetype)initWithAdUnitID:(NSString *)adUnitID adSize:(YMAAdSize *)adSize;
- (void)loadAd;
@property (nonatomic, weak) id delegate;
@end

#ifdef __cplusplus
extern "C" {
#endif

// Forward declarations
void yandex_ads_init();
void yandex_ads_deinit();
void yandex_ads_load_banner(const char* block_id, bool on_top);
void yandex_ads_show_banner();
void yandex_ads_hide_banner();
void yandex_ads_load_rewarded(const char* block_id);
void yandex_ads_show_rewarded();
bool yandex_ads_is_initialized();

#ifdef __cplusplus
}
#endif

// Global variables
static YMABannerView *g_bannerView = nil;
static YMARewardedAd *g_rewardedAd = nil;
static bool g_isInitialized = false;
static NSString *g_currentRewardedBlockID = nil;

// Callbacks to Godot (will be set from GDScript)
typedef void (*BannerLoadedCallback)();
typedef void (*BannerFailedCallback)(int error_code);
typedef void (*RewardedLoadedCallback)();
typedef void (*RewardedFailedCallback)(int error_code);
typedef void (*RewardedEarnedCallback)(const char* currency, int amount);
typedef void (*RewardedClosedCallback)();

static BannerLoadedCallback g_banner_loaded_callback = nullptr;
static BannerFailedCallback g_banner_failed_callback = nullptr;
static RewardedLoadedCallback g_rewarded_loaded_callback = nullptr;
static RewardedFailedCallback g_rewarded_failed_callback = nullptr;
static RewardedEarnedCallback g_rewarded_earned_callback = nullptr;
static RewardedClosedCallback g_rewarded_closed_callback = nullptr;

// Protocol forward declarations
@protocol YMABannerViewDelegate <NSObject>
@optional
- (void)bannerViewDidLoad:(YMABannerView *)bannerView;
- (void)bannerView:(YMABannerView *)bannerView didFailLoadingWithError:(NSError *)error;
@end

@protocol YMARewardedAdDelegate <NSObject>
@optional
- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id)reward;
- (void)rewardedAdDidDismiss:(YMARewardedAd *)rewardedAd;
- (void)rewardedAd:(YMARewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error;
@end

@protocol YMAReward <NSObject>
@property (nonatomic, readonly) NSNumber *amount;
@property (nonatomic, readonly) NSString *type;
@end

// Banner Delegate
@interface YandexBannerDelegate : NSObject <YMABannerViewDelegate>
@end

@implementation YandexBannerDelegate

- (void)bannerViewDidLoad:(YMABannerView *)bannerView {
    NSLog(@"✅ Yandex banner loaded");
    if (g_banner_loaded_callback) {
        g_banner_loaded_callback();
    }
}

- (void)bannerView:(YMABannerView *)bannerView didFailLoadingWithError:(NSError *)error {
    NSLog(@"❌ Yandex banner failed: %@", error.localizedDescription);
    if (g_banner_failed_callback) {
        g_banner_failed_callback((int)error.code);
    }
}

@end

static YandexBannerDelegate *g_bannerDelegate = nil;

// Rewarded Delegate
@interface YandexRewardedDelegate : NSObject <YMARewardedAdDelegate>
@end

@implementation YandexRewardedDelegate

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id)reward {
    // Use performSelector to access properties without importing protocol
    NSNumber *amount = [reward performSelector:@selector(amount)];
    NSString *type = [reward performSelector:@selector(type)];
    
    NSLog(@"🎉 Yandex reward earned: %@ %@", amount, type);
    if (g_rewarded_earned_callback) {
        const char* currency = [type UTF8String];
        int amountValue = [amount intValue];
        g_rewarded_earned_callback(currency, amountValue);
    }
}

- (void)rewardedAdDidDismiss:(YMARewardedAd *)rewardedAd {
    NSLog(@"🔚 Yandex rewarded closed");
    if (g_rewarded_closed_callback) {
        g_rewarded_closed_callback();
    }
    // Reload for next time
    if (g_currentRewardedBlockID) {
        yandex_ads_load_rewarded([g_currentRewardedBlockID UTF8String]);
    }
}

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    NSLog(@"❌ Yandex rewarded show failed: %@", error.localizedDescription);
}

@end

static YandexRewardedDelegate *g_rewardedDelegate = nil;

// File logging helper
void log_to_file(NSString *message) {
    NSString *logPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] 
                         stringByAppendingPathComponent:@"yandex_ads_log.txt"];
    NSString *timestamp = [NSString stringWithFormat:@"[%@] ", [NSDate date]];
    NSString *logMessage = [NSString stringWithFormat:@"%@%@\n", timestamp, message];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else {
        [logMessage writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

// Implementation
void yandex_ads_init() {
    NSLog(@"🟡 [YANDEX] Initializing Yandex Mobile Ads SDK...");
    log_to_file(@"🟡 [YANDEX] yandex_ads_init() CALLED!");
    log_to_file(@"🟡 [YANDEX] Plugin loaded and init called");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        log_to_file(@"🟡 [YANDEX] Starting SDK initialization...");
        [YMAMobileAds enableLogging];
        [YMAMobileAds initializeSDKWithCompletionHandler:^{
            NSLog(@"✅ [YANDEX] Yandex Mobile Ads SDK initialized successfully");
            log_to_file(@"✅ [YANDEX] SDK initialized successfully");
            g_isInitialized = true;
        }];
        
        g_bannerDelegate = [[YandexBannerDelegate alloc] init];
        g_rewardedDelegate = [[YandexRewardedDelegate alloc] init];
        
        NSLog(@"✅ [YANDEX] Delegates created");
        log_to_file(@"✅ [YANDEX] Delegates created");
    });
}

void yandex_ads_deinit() {
    NSLog(@"🟡 Deinitializing Yandex Ads...");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_bannerView) {
            [g_bannerView removeFromSuperview];
            g_bannerView = nil;
        }
        g_rewardedAd = nil;
        g_bannerDelegate = nil;
        g_rewardedDelegate = nil;
        g_currentRewardedBlockID = nil;
    });
}

void yandex_ads_load_banner(const char* block_id, bool on_top) {
    if (!g_isInitialized) {
        NSLog(@"❌ Yandex SDK not initialized yet");
        if (g_banner_failed_callback) {
            g_banner_failed_callback(1);
        }
        return;
    }
    
    NSString *blockID = [NSString stringWithUTF8String:block_id];
    NSLog(@"📊 Loading Yandex banner: %@", blockID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Create adaptive banner size
        CGFloat width = UIScreen.mainScreen.bounds.size.width;
        YMAAdSize *adSize = [YMAAdSize stickyAdSizeWithContainerWidth:width];
        
        // Create banner
        g_bannerView = [[YMABannerView alloc] initWithAdUnitID:blockID adSize:adSize];
        g_bannerView.delegate = g_bannerDelegate;
        
        // Load ad
        [g_bannerView loadAd];
    });
}

void yandex_ads_show_banner() {
    if (!g_bannerView) {
        NSLog(@"❌ Banner not loaded");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC && rootVC.view) {
            [rootVC.view addSubview:g_bannerView];
            
            // Position at top
            g_bannerView.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[
                [g_bannerView.topAnchor constraintEqualToAnchor:rootVC.view.safeAreaLayoutGuide.topAnchor],
                [g_bannerView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor]
            ]];
            
            NSLog(@"✅ Yandex banner shown");
        }
    });
}

void yandex_ads_hide_banner() {
    if (!g_bannerView) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [g_bannerView removeFromSuperview];
        NSLog(@"✅ Yandex banner hidden");
    });
}

void yandex_ads_load_rewarded(const char* block_id) {
    if (!g_isInitialized) {
        NSLog(@"❌ Yandex SDK not initialized yet");
        if (g_rewarded_failed_callback) {
            g_rewarded_failed_callback(1);
        }
        return;
    }
    
    NSString *blockID = [NSString stringWithUTF8String:block_id];
    g_currentRewardedBlockID = blockID;
    NSLog(@"🎬 Loading Yandex rewarded: %@", blockID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        YMAAdRequestConfiguration *config = [[YMAAdRequestConfiguration alloc] initWithAdUnitID:blockID];
        
        [YMARewardedAd loadWithRequestConfiguration:config
                                  completionHandler:^(YMARewardedAd *ad, NSError *error) {
            if (error) {
                NSLog(@"❌ Yandex rewarded failed: %@", error.localizedDescription);
                if (g_rewarded_failed_callback) {
                    g_rewarded_failed_callback((int)error.code);
                }
            } else {
                NSLog(@"✅ Yandex rewarded loaded");
                g_rewardedAd = ad;
                g_rewardedAd.delegate = g_rewardedDelegate;
                if (g_rewarded_loaded_callback) {
                    g_rewarded_loaded_callback();
                }
            }
        }];
    });
}

void yandex_ads_show_rewarded() {
    if (!g_rewardedAd) {
        NSLog(@"❌ Rewarded ad not loaded");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            [g_rewardedAd showFromViewController:rootVC];
            NSLog(@"▶️ Showing Yandex rewarded");
        }
    });
}

bool yandex_ads_is_initialized() {
    return g_isInitialized;
}

// Callback setters (called from GDScript)
#ifdef __cplusplus
extern "C" {
#endif

void yandex_ads_set_banner_loaded_callback(BannerLoadedCallback callback) {
    g_banner_loaded_callback = callback;
}

void yandex_ads_set_banner_failed_callback(BannerFailedCallback callback) {
    g_banner_failed_callback = callback;
}

void yandex_ads_set_rewarded_loaded_callback(RewardedLoadedCallback callback) {
    g_rewarded_loaded_callback = callback;
}

void yandex_ads_set_rewarded_failed_callback(RewardedFailedCallback callback) {
    g_rewarded_failed_callback = callback;
}

void yandex_ads_set_rewarded_earned_callback(RewardedEarnedCallback callback) {
    g_rewarded_earned_callback = callback;
}

void yandex_ads_set_rewarded_closed_callback(RewardedClosedCallback callback) {
    g_rewarded_closed_callback = callback;
}

#ifdef __cplusplus
}
#endif
