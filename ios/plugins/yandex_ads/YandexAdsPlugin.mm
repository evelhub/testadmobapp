#import "YandexAdsPlugin.h"
#import <YandexMobileAds/YandexMobileAds.h>
#import <UIKit/UIKit.h>

@interface YandexAdsPlugin () <YMABannerViewDelegate, YMARewardedAdDelegate>
@property (nonatomic, strong) YMABannerView *bannerView;
@property (nonatomic, strong) YMARewardedAd *rewardedAd;
@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, strong) NSString *currentRewardedBlockID;
@end

@implementation YandexAdsPlugin

+ (instancetype)sharedInstance {
    static YandexAdsPlugin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YandexAdsPlugin alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isInitialized = NO;
        NSLog(@"🟡 [YANDEX-PLUGIN] YandexAdsPlugin instance created");
    }
    return self;
}

- (void)initializeSDK {
    NSLog(@"🟡 [YANDEX-PLUGIN] Initializing Yandex Mobile Ads SDK...");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [YMAMobileAds enableLogging];
        [YMAMobileAds initializeSDKWithCompletionHandler:^{
            NSLog(@"✅ [YANDEX-PLUGIN] Yandex Mobile Ads SDK initialized successfully");
            self.isInitialized = YES;
        }];
    });
}

- (void)loadBannerWithBlockID:(NSString *)blockID onTop:(BOOL)onTop {
    if (!self.isInitialized) {
        NSLog(@"❌ [YANDEX-PLUGIN] SDK not initialized yet");
        return;
    }
    
    NSLog(@"📊 [YANDEX-PLUGIN] Loading banner: %@", blockID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat width = UIScreen.mainScreen.bounds.size.width;
        YMAAdSize *adSize = [YMAAdSize stickyAdSizeWithContainerWidth:width];
        
        self.bannerView = [[YMABannerView alloc] initWithAdUnitID:blockID adSize:adSize];
        self.bannerView.delegate = self;
        [self.bannerView loadAd];
    });
}

- (void)showBanner {
    if (!self.bannerView) {
        NSLog(@"❌ [YANDEX-PLUGIN] Banner not loaded");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC && rootVC.view) {
            [rootVC.view addSubview:self.bannerView];
            
            self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[
                [self.bannerView.topAnchor constraintEqualToAnchor:rootVC.view.safeAreaLayoutGuide.topAnchor],
                [self.bannerView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor]
            ]];
            
            NSLog(@"✅ [YANDEX-PLUGIN] Banner shown");
        }
    });
}

- (void)hideBanner {
    if (!self.bannerView) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bannerView removeFromSuperview];
        NSLog(@"✅ [YANDEX-PLUGIN] Banner hidden");
    });
}

- (void)loadRewardedWithBlockID:(NSString *)blockID {
    if (!self.isInitialized) {
        NSLog(@"❌ [YANDEX-PLUGIN] SDK not initialized yet");
        return;
    }
    
    self.currentRewardedBlockID = blockID;
    NSLog(@"🎬 [YANDEX-PLUGIN] Loading rewarded: %@", blockID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        YMAAdRequestConfiguration *config = [[YMAAdRequestConfiguration alloc] initWithAdUnitID:blockID];
        
        [YMARewardedAd loadWithRequestConfiguration:config
                                  completionHandler:^(YMARewardedAd *ad, NSError *error) {
            if (error) {
                NSLog(@"❌ [YANDEX-PLUGIN] Rewarded failed: %@", error.localizedDescription);
            } else {
                NSLog(@"✅ [YANDEX-PLUGIN] Rewarded loaded");
                self.rewardedAd = ad;
                self.rewardedAd.delegate = self;
            }
        }];
    });
}

- (void)showRewarded {
    if (!self.rewardedAd) {
        NSLog(@"❌ [YANDEX-PLUGIN] Rewarded ad not loaded");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            [self.rewardedAd showFromViewController:rootVC];
            NSLog(@"▶️ [YANDEX-PLUGIN] Showing rewarded");
        }
    });
}

- (BOOL)isInitialized {
    return _isInitialized;
}

#pragma mark - YMABannerViewDelegate

- (void)bannerViewDidLoad:(YMABannerView *)bannerView {
    NSLog(@"✅ [YANDEX-PLUGIN] Banner loaded");
}

- (void)bannerView:(YMABannerView *)bannerView didFailLoadingWithError:(NSError *)error {
    NSLog(@"❌ [YANDEX-PLUGIN] Banner failed: %@", error.localizedDescription);
}

#pragma mark - YMARewardedAdDelegate

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id<YMAReward>)reward {
    NSLog(@"🎉 [YANDEX-PLUGIN] Reward earned: %@ %@", reward.amount, reward.type);
}

- (void)rewardedAdDidDismiss:(YMARewardedAd *)rewardedAd {
    NSLog(@"🔚 [YANDEX-PLUGIN] Rewarded closed");
    // Reload for next time
    if (self.currentRewardedBlockID) {
        [self loadRewardedWithBlockID:self.currentRewardedBlockID];
    }
}

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    NSLog(@"❌ [YANDEX-PLUGIN] Rewarded show failed: %@", error.localizedDescription);
}

@end

// C bridge for Godot
extern "C" {
    void yandex_ads_init() {
        NSLog(@"🟡 [YANDEX-C-BRIDGE] yandex_ads_init() called");
        [[YandexAdsPlugin sharedInstance] initializeSDK];
    }
    
    void yandex_ads_deinit() {
        NSLog(@"🟡 [YANDEX-C-BRIDGE] yandex_ads_deinit() called");
    }
}
