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
+ (instancetype)configWithPlayerSuperviewSelector:(nullable SEL)playerSuperviewSelector autoplayDelegate:(id<SJPlayerAutoplayDelegate>)delegate {
    NSParameterAssert(delegate != nil);
    
    SJPlayerAutoplayConfig *config = [[self alloc] init];
    config->_autoplayDelegate = delegate;
    config->_animationType = SJAutoplayScrollAnimationTypeMiddle;
    config->_autoplayPosition = SJAutoplayPositionMiddle;
    config->_playerSuperviewSelector = playerSuperviewSelector;
    return config;
}
@end


@implementation SJPlayerAutoplayConfig (SJDeprecated)
+ (instancetype)configWithAutoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate {
    return [self configWithPlayerSuperviewSelector:NULL autoplayDelegate:autoplayDelegate];
}

+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJPlayerAutoplayDelegate>)autoplayDelegate {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(autoplayDelegate != nil);
    
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithAutoplayDelegate:autoplayDelegate];
    config->_playerSuperviewTag = playerSuperviewTag;
    return config;
}
@end
