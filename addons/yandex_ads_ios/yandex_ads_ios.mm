// yandex_ads_ios.mm
// Objective-C++ bridge for Yandex Mobile Ads SDK

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __OBJC__
#import <YandexMobileAds/YandexMobileAds.h>
#endif

#include "core/config/engine.h"
#include "core/object/class_db.h"

class YandexAdsIOS : public Object {
    GDCLASS(YandexAdsIOS, Object);
    
private:
    YMABannerView *bannerView;
    YMARewardedAd *rewardedAd;
    bool isInitialized;
    
protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("load_banner", "block_id", "on_top"), &YandexAdsIOS::load_banner);
        ClassDB::bind_method(D_METHOD("show_banner"), &YandexAdsIOS::show_banner);
        ClassDB::bind_method(D_METHOD("hide_banner"), &YandexAdsIOS::hide_banner);
        ClassDB::bind_method(D_METHOD("load_rewarded", "block_id"), &YandexAdsIOS::load_rewarded);
        ClassDB::bind_method(D_METHOD("show_rewarded"), &YandexAdsIOS::show_rewarded);
        
        ADD_SIGNAL(MethodInfo("banner_loaded"));
        ADD_SIGNAL(MethodInfo("banner_failed", PropertyInfo(Variant::INT, "error_code")));
        ADD_SIGNAL(MethodInfo("rewarded_loaded"));
        ADD_SIGNAL(MethodInfo("rewarded_failed", PropertyInfo(Variant::INT, "error_code")));
        ADD_SIGNAL(MethodInfo("rewarded_earned", PropertyInfo(Variant::STRING, "currency"), PropertyInfo(Variant::INT, "amount")));
        ADD_SIGNAL(MethodInfo("rewarded_closed"));
    }
    
public:
    YandexAdsIOS() {
        isInitialized = false;
        bannerView = nil;
        rewardedAd = nil;
        
        // Initialize Yandex Mobile Ads
        [YMAMobileAds enableLogging];
        [YMAMobileAds initializeSDKWithCompletionHandler:^{
            NSLog(@"✅ Yandex Mobile Ads SDK initialized");
            isInitialized = true;
        }];
    }
    
    ~YandexAdsIOS() {
        if (bannerView) {
            [bannerView removeFromSuperview];
            bannerView = nil;
        }
        rewardedAd = nil;
    }
    
    void load_banner(String block_id, bool on_top) {
        if (!isInitialized) {
            NSLog(@"❌ Yandex SDK not initialized yet");
            emit_signal("banner_failed", 1);
            return;
        }
        
        NSString *blockID = [NSString stringWithUTF8String:block_id.utf8().get_data()];
        NSLog(@"📊 Loading Yandex banner: %@", blockID);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create banner
            YMAAdSize *adSize = [YMAAdSize stickyAdSizeWithContainerWidth:320];
            bannerView = [[YMABannerView alloc] initWithAdUnitID:blockID adSize:adSize];
            
            // Set delegate
            bannerView.delegate = (__bridge id<YMABannerViewDelegate>)(__bridge void *)this;
            
            // Load ad
            [bannerView loadAd];
        });
    }
    
    void show_banner() {
        if (!bannerView) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (rootVC && rootVC.view) {
                [rootVC.view addSubview:bannerView];
                
                // Position at top
                bannerView.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[
                    [bannerView.topAnchor constraintEqualToAnchor:rootVC.view.safeAreaLayoutGuide.topAnchor],
                    [bannerView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor]
                ]];
            }
        });
    }
    
    void hide_banner() {
        if (!bannerView) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [bannerView removeFromSuperview];
        });
    }
    
    void load_rewarded(String block_id) {
        if (!isInitialized) {
            NSLog(@"❌ Yandex SDK not initialized yet");
            emit_signal("rewarded_failed", 1);
            return;
        }
        
        NSString *blockID = [NSString stringWithUTF8String:block_id.utf8().get_data()];
        NSLog(@"🎬 Loading Yandex rewarded: %@", blockID);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            YMAAdRequestConfiguration *config = [[YMAAdRequestConfiguration alloc] initWithAdUnitID:blockID];
            
            [YMARewardedAd loadWithRequestConfiguration:config
                                      completionHandler:^(YMARewardedAd *ad, NSError *error) {
                if (error) {
                    NSLog(@"❌ Yandex rewarded failed: %@", error.localizedDescription);
                    emit_signal("rewarded_failed", (int)error.code);
                } else {
                    NSLog(@"✅ Yandex rewarded loaded");
                    rewardedAd = ad;
                    rewardedAd.delegate = (__bridge id<YMARewardedAdDelegate>)(__bridge void *)this;
                    emit_signal("rewarded_loaded");
                }
            }];
        });
    }
    
    void show_rewarded() {
        if (!rewardedAd) {
            NSLog(@"❌ Rewarded ad not loaded");
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (rootVC) {
                [rewardedAd showFromViewController:rootVC];
            }
        });
    }
    
    // Delegate callbacks (simplified - full implementation needs proper bridging)
    void on_banner_loaded() {
        NSLog(@"✅ Banner loaded callback");
        emit_signal("banner_loaded");
    }
    
    void on_rewarded_earned(String currency, int amount) {
        NSLog(@"🎉 Rewarded earned: %d %s", amount, currency.utf8().get_data());
        emit_signal("rewarded_earned", currency, amount);
    }
};

// Register singleton
void register_yandex_ads_ios_types() {
    ClassDB::register_class<YandexAdsIOS>();
    Engine::get_singleton()->add_singleton(Engine::Singleton("YandexAdsIOS", YandexAdsIOS::get_singleton()));
}

void unregister_yandex_ads_ios_types() {
    // Cleanup
}
