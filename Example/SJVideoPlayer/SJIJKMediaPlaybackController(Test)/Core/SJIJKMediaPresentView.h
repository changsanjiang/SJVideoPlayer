//
//  SJIJKMediaPresentView.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerPlaybackControllerDefines.h"
@class SJIJKMediaPlayer;

NS_ASSUME_NONNULL_BEGIN
@interface SJIJKMediaPresentView : UIView
- (instancetype)initWithFrame:(CGRect)frame player:(SJIJKMediaPlayer *)player;

@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;
@property (nonatomic, strong, nullable) SJIJKMediaPlayer *player;
@property (nonatomic, copy, null_resettable) SJVideoGravity videoGravity;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
