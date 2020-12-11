//
//  SJPictureInPictureControllerDefines.h
//  Pods
//
//  Created by BlueDancer on 2020/9/26.
//

#ifndef SJPictureInPictureControllerDefines_h
#define SJPictureInPictureControllerDefines_h
@protocol SJPictureInPictureControllerDelegate;
///
/// 画中画状态
///
typedef NS_ENUM(NSUInteger, SJPictureInPictureStatus) {
    SJPictureInPictureStatusUnknown,
    /// 启动中
    SJPictureInPictureStatusStarting,
    /// 启动完毕, 运行中
    SJPictureInPictureStatusRunning,
    /// 正在停止
    SJPictureInPictureStatusStopping,
    /// 停止画中画
    SJPictureInPictureStatusStopped,
} API_AVAILABLE(ios(14.0));

NS_ASSUME_NONNULL_BEGIN
API_AVAILABLE(ios(14.0)) @protocol SJPictureInPictureController <NSObject>
+ (BOOL)isPictureInPictureSupported;

@property (nonatomic) BOOL requiresLinearPlayback;
@property (nonatomic, weak, nullable) id<SJPictureInPictureControllerDelegate> delegate;
@property (nonatomic, readonly) SJPictureInPictureStatus status;
- (void)startPictureInPicture;
- (void)stopPictureInPicture;
@end

API_AVAILABLE(ios(14.0)) @protocol SJPictureInPictureControllerDelegate <NSObject>
- (void)pictureInPictureController:(id<SJPictureInPictureController>)controller statusDidChange:(SJPictureInPictureStatus)status;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPictureInPictureControllerDefines_h */
