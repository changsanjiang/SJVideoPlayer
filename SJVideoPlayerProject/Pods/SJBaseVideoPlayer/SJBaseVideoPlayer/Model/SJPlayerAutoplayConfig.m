//
//  SJPlayerAutoplayConfig.m
//  Masonry
//
//  Created by BlueDancer on 2018/7/10.
//

#import "SJPlayerAutoplayConfig.h"

@implementation SJPlayerAutoplayConfig
+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate {
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig new];
    config->_playerSuperviewTag = playerSuperviewTag;
    config->_autoplayDelegate = autoplayDelegate;
    return config;
}
@end
