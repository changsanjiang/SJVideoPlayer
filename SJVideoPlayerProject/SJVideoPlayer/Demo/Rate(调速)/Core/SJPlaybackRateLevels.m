//
//  SJPlaybackRateLevels.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJPlaybackRateLevels.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlaybackRateLevels
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _level = SJPlaybackRateLevel_1;
    return self;
}
- (void)setLevel:(SJPlaybackRateLevel)level {
    if ( level == _level ) return;
    _level = level;
    if ( _levelDidChangeExeBlock ) _levelDidChangeExeBlock(self);
}

- (NSString *)toString:(SJPlaybackRateLevel)level {
    switch ( level ) {
        case SJPlaybackRateLevel_1:
            return @"1.0x";
        case SJPlaybackRateLevel_2:
            return @"1.25x";
        case SJPlaybackRateLevel_3:
            return @"1.5x";
        case SJPlaybackRateLevel_4:
            return @"2.0x";
    }
}
@end
NS_ASSUME_NONNULL_END
