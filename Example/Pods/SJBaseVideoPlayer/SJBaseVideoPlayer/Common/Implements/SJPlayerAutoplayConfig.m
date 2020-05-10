//
//  SJPlayerAutoplayConfig.m
//  Masonry
//
//  Created by 畅三江 on 2018/7/10.
//

#import "SJPlayerAutoplayConfig.h"

@interface SJPlayerAutoplayConfig ()
@property (nonatomic) NSInteger playerSuperviewTag __deprecated;
@end

@implementation SJPlayerAutoplayConfig
+ (instancetype)configWithAutoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate {
    NSParameterAssert(autoplayDelegate != nil);
    
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig new];
    config->_autoplayDelegate = autoplayDelegate;
    config->_animationType = SJAutoplayScrollAnimationTypeMiddle;
    config->_autoplayPosition = SJAutoplayPositionMiddle;
    return config;
}
@end


@implementation SJPlayerAutoplayConfig (SJDeprecated)
+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(autoplayDelegate != nil);
    
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithAutoplayDelegate:autoplayDelegate];
    config->_playerSuperviewTag = playerSuperviewTag;
    return config;
}
@end
