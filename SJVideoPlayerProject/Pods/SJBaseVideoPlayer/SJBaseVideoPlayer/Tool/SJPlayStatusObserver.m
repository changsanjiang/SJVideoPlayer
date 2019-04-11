//
//  SJPlayStatusObserver.m
//  Pods
//
//  Created by BlueDancer on 2019/4/10.
//

#import "SJPlayStatusObserver.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlayStatusObserver
@synthesize playStatusDidChangeExeBlock = _playStatusDidChangeExeBlock;
- (instancetype)initWithPlayer:(id<SJBaseVideoPlayer>)player {
    self = [super init];
    if ( !self ) return nil;
    [(id)player sj_addObserver:self forKeyPath:@"playStatus"];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable SJBaseVideoPlayer *)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( _playStatusDidChangeExeBlock ) _playStatusDidChangeExeBlock(object);
}
@end
NS_ASSUME_NONNULL_END
