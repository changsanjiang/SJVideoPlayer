//
//  SJPlayerAutoplayConfig.h
//  Masonry
//
//  Created by 畅三江 on 2018/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlayerAutoplayDelegate;

typedef NS_ENUM(NSUInteger, SJAutoplayScrollAnimationType) {
    SJAutoplayScrollAnimationTypeNone,
    SJAutoplayScrollAnimationTypeTop,
    SJAutoplayScrollAnimationTypeMiddle,
};

typedef NS_ENUM(NSUInteger, SJAutoplayPosition) {
    SJAutoplayPositionTop,
    SJAutoplayPositionMiddle,
};

@interface SJPlayerAutoplayConfig : NSObject
+ (instancetype)configWithPlayerSuperviewKey:(nullable NSString *)playerSuperviewKey autoplayDelegate:(id<SJPlayerAutoplayDelegate>)delegate;

@property (nonatomic, copy, nullable) NSString *playerSuperviewKey;

@property (nonatomic, weak, nullable, readonly) id<SJPlayerAutoplayDelegate> autoplayDelegate;

/// 滚动的动画类型
/// default is .Middle;
@property (nonatomic) SJAutoplayScrollAnimationType animationType;
/// default is .Middle;
@property (nonatomic) SJAutoplayPosition autoplayPosition;
/// 可播区域的insets
@property (nonatomic) UIEdgeInsets playableAreaInsets;
@end

@protocol SJPlayerAutoplayDelegate <NSObject>
- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath;
@end



/// 已弃用
@interface SJPlayerAutoplayConfig (SJDeprecated)
+ (instancetype)configWithAutoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate  __deprecated_msg("use `configWithPlayerSuperviewKey:autoplayDelegate:`;");
+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate __deprecated_msg("use `configWithPlayerSuperviewKey:autoplayDelegate:`;");
@property (nonatomic, readonly) NSInteger playerSuperviewTag __deprecated_msg("use `config.playerSuperviewKey`");
@end
NS_ASSUME_NONNULL_END
