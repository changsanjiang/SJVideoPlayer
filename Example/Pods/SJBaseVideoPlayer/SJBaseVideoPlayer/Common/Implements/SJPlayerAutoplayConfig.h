//
//  SJPlayerAutoplayConfig.h
//  Masonry
//
//  Created by 畅三江 on 2018/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlayerAutoplayDelegate;

@interface SJPlayerAutoplayConfig : NSObject
+ (instancetype)configWithPlayerSuperviewSelector:(nullable SEL)playerSuperviewSelector autoplayDelegate:(id<SJPlayerAutoplayDelegate>)delegate;

@property (nonatomic, nullable) SEL playerSuperviewSelector;

@property (nonatomic, weak, nullable, readonly) id<SJPlayerAutoplayDelegate> autoplayDelegate;

/// 滑动方向默认为 垂直方向, 当 UICollectionView 水平滑动时, 记得设置此属性;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;

/// 可播区域的insets
@property (nonatomic) UIEdgeInsets playableAreaInsets;
@end

@protocol SJPlayerAutoplayDelegate <NSObject>
- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath;
@end



/// 已弃用
@interface SJPlayerAutoplayConfig (SJDeprecated)
+ (instancetype)configWithAutoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate  __deprecated_msg("use `configWithPlayerSuperviewSelector:autoplayDelegate:`;");
+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate __deprecated_msg("use `configWithPlayerSuperviewSelector:autoplayDelegate:`;");
@property (nonatomic, readonly) NSInteger playerSuperviewTag __deprecated_msg("use `config.scrollViewSelector`");
@end
NS_ASSUME_NONNULL_END
