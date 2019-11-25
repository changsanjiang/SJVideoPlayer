//
//  SJPlayerAutoplayConfig.m
//  Masonry
//
//  Created by 畅三江 on 2018/7/10.
//

#import "SJPlayerAutoplayConfig.h"

@implementation SJPlayerAutoplayConfig
+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(autoplayDelegate != nil);
    
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig new];
    config->_playerSuperviewTag = playerSuperviewTag;
    config->_autoplayDelegate = autoplayDelegate;
    config->_animationType = SJAutoplayScrollAnimationTypeMiddle;
    config->_autoplayPosition = SJAutoplayPositionMiddle;
    return config;
}
@end
