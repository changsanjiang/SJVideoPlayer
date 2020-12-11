//
//  SJAVPictureInPictureController.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2020/9/26.
//

#import <AVFoundation/AVFoundation.h>
#import "SJPictureInPictureControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(14.0)) @interface SJAVPictureInPictureController : NSObject<SJPictureInPictureController>
+ (BOOL)isPictureInPictureSupported;
- (nullable instancetype)initWithLayer:(AVPlayerLayer *)layer delegate:(id<SJPictureInPictureControllerDelegate>)delegate;

@property (nonatomic) BOOL requiresLinearPlayback;
@property (nonatomic, readonly) SJPictureInPictureStatus status;
@property (nonatomic, readonly) BOOL wantsPictureInPictureStart;
@property (nonatomic, readonly, getter=isAvailable) BOOL available;
@property (nonatomic, readonly, getter=isEnabled) BOOL enabled;
- (void)startPictureInPicture;
- (void)stopPictureInPicture;
@end
NS_ASSUME_NONNULL_END
