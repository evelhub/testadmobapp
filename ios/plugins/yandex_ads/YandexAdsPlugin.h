#import <Foundation/Foundation.h>

@interface YandexAdsPlugin : NSObject

+ (instancetype)sharedInstance;
- (void)initializeSDK;
- (void)loadBannerWithBlockID:(NSString *)blockID onTop:(BOOL)onTop;
- (void)showBanner;
- (void)hideBanner;
- (void)loadRewardedWithBlockID:(NSString *)blockID;
- (void)showRewarded;
- (BOOL)isInitialized;

@end
