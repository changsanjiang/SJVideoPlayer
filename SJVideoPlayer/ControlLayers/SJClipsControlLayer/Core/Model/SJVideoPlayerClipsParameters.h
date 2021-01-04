//
//  SJVideoPlayerClipsParameters.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerClipsDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerClipsParameters : NSObject<SJVideoPlayerClipsParameters>
- (instancetype)initWithOperation:(SJVideoPlayerClipsOperation)operation range:(CMTimeRange)range;
@end

NS_ASSUME_NONNULL_END
