//
//  SJPlayStatusObserver.h
//  Pods
//
//  Created by BlueDancer on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "SJBaseVideoPlayerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayStatusObserver : NSObject<SJPlayStatusObserver>
- (instancetype)initWithPlayer:(id<SJBaseVideoPlayer>)player;
@end
NS_ASSUME_NONNULL_END
