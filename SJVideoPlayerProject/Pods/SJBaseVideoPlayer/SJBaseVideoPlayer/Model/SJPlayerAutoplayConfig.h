//
//  SJPlayerAutoplayConfig.h
//  Masonry
//
//  Created by BlueDancer on 2018/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlayerAutoplayDelegate;

typedef NS_ENUM(NSUInteger, SJAutoplayScrollAnimationType) {
    SJAutoplayScrollAnimationTypeNone,
    SJAutoplayScrollAnimationTypeTop,
    SJAutoplayScrollAnimationTypeMiddle,
};

@interface SJPlayerAutoplayConfig : NSObject
+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate;

@property (nonatomic, readonly) NSInteger playerSuperviewTag;
@property (nonatomic, weak, nullable, readonly) id<SJPlayerAutoplayDelegate> autoplayDelegate;
@property (nonatomic) SJAutoplayScrollAnimationType animationType;
@end

@protocol SJPlayerAutoplayDelegate <NSObject>
- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
