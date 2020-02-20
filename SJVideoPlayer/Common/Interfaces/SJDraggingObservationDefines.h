//
//  SJDraggingObservationDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/11/27.
//

#ifndef SJDraggingObservationDefines_h
#define SJDraggingObservationDefines_h

NS_ASSUME_NONNULL_BEGIN
@protocol SJDraggingObservation <NSObject>
///
/// 拖动开始的回调
///
@property (nonatomic, copy, nullable) void(^willBeginDraggingExeBlock)(NSTimeInterval time);

///
/// 拖动中的回调
///
@property (nonatomic, copy, nullable) void(^didMoveExeBlock)(NSTimeInterval time);

///
/// 将要结束的回调
///
@property (nonatomic, copy, nullable) void(^willEndDraggingExeBlock)(NSTimeInterval time);

///
/// 结束了的回调
///
@property (nonatomic, copy, nullable) void(^didEndDraggingExeBlock)(NSTimeInterval time);
@end
NS_ASSUME_NONNULL_END

#endif /* SJDraggingObservationDefines_h */
