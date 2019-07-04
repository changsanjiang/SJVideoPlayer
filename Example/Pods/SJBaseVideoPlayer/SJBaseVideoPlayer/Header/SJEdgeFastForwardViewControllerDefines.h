//
//  SJEdgeFastForwardViewControllerDefines.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/6/30.
//

#ifndef SJEdgeFastForwardViewControllerDefines_h
#define SJEdgeFastForwardViewControllerDefines_h
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SJFastForwardTriggeredPosition_Left,
    SJFastForwardTriggeredPosition_Right,
} SJFastForwardTriggeredPosition;

@protocol SJEdgeFastForwardViewControllerProtocol <NSObject>

/// 是否开启左右边缘触发快进控制, 注意: 默认为 不开启
///
/// - default value is NO.
@property (nonatomic, getter=isEnabled) BOOL enabled;

/// 快进快退触发区域的宽度. 默认为80.
///
@property (nonatomic) CGFloat triggerAreaWidth;

/// 快进快退多长时间. 默认10秒.
///
@property (nonatomic) NSTimeInterval spanSecs;

///
/// - default value is UIColor.orangeColor
@property (nonatomic, strong, null_resettable) UIColor *blockColor;

/// 显示
///
- (void)showFastForwardView:(SJFastForwardTriggeredPosition)position;

/// 以下属性由播放器自动维护
///
/// - target 为播放器呈现视图, 将来可以将fastForwardView添加到此视图中
@property (nonatomic, weak, nullable) UIView *target;
@end

#endif /* SJEdgeFastForwardViewControllerDefines_h */
