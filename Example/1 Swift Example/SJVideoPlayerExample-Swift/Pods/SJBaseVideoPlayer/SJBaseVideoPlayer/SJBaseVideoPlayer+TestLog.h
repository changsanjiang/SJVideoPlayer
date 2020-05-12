//
//  SJBaseVideoPlayer+TestLog.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/9/11.
//

#ifdef SJDEBUG
#import "SJBaseVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseVideoPlayer (TestLog)
- (void)showLog_TimeControlStatus;
- (void)showLog_AssetStatus;
@end
NS_ASSUME_NONNULL_END
#endif
