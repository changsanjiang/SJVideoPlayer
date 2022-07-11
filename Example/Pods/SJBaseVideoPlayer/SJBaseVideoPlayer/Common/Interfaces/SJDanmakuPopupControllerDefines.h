//
//  SJDanmakuPopupControllerDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/11/12.
//

#ifndef SJDanmakuPopupControllerDefines_h
#define SJDanmakuPopupControllerDefines_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol SJDanmakuItem, SJDanmakuPopupControllerObserver;

///
/// 弹幕控制
///
NS_ASSUME_NONNULL_BEGIN
@protocol SJDanmakuPopupController <NSObject>
- (instancetype)initWithNumberOfTracks:(NSUInteger)numberOfTracks;

///
/// 是否禁用
///
///     禁用后, 将无法添加弹幕
///
@property (nonatomic, getter=isDisabled) BOOL disabled;

///
/// 发送一条弹幕, 弹幕将自动显示
///
///     该弹幕将会在某一条队列中适时显示
///
- (void)enqueue:(id<SJDanmakuItem>)danmaku;

///
/// 移除未显示的弹幕
///
- (void)emptyQueue;

///
/// 移除已显示的弹幕
///
- (void)removeDisplayedItems;

///
/// 移除所有弹幕(已显示的弹幕也会被移除)
///
- (void)removeAll;

///
/// 是否已暂停移动
///
@property (nonatomic, readonly, getter=isPaused) BOOL paused;

///
/// 使暂停, 弹幕将停止移动
///
- (void)pause;

///
/// 使恢复, 弹幕将恢复移动
///
- (void)resume;

///
/// 控制器视图
///
@property (nonatomic, strong, readonly) __kindof UIView *view;

///
/// 获取观察者
///
- (id<SJDanmakuPopupControllerObserver>)getObserver;

///
/// 未显示的弹幕数量
///
@property (nonatomic, readonly) NSInteger queueSize;
@property (nonatomic) NSInteger numberOfTracks;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end


@protocol SJDanmakuItem <NSObject>
- (instancetype)initWithContent:(NSAttributedString *)content;
- (instancetype)initWithCustomView:(__kindof UIView *)customView;

@property (nonatomic, copy, readonly, nullable) NSAttributedString *content;
@property (nonatomic, strong, readonly, nullable) __kindof UIView *customView;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

@protocol SJDanmakuPopupControllerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^onDisabledChanged)(id<SJDanmakuPopupController> controller);
@property (nonatomic, copy, nullable) void(^onPausedChanged)(id<SJDanmakuPopupController> controller);

/// 该条弹幕已出队列, 将要显示时调用
@property (nonatomic, copy, nullable) void(^willDisplayItem)(id<SJDanmakuPopupController> controller, id<SJDanmakuItem> item);
/// 结束显示时调用
@property (nonatomic, copy, nullable) void(^didEndDisplayingItem)(id<SJDanmakuPopupController> controller, id<SJDanmakuItem> item);
@end
NS_ASSUME_NONNULL_END
#endif /* SJDanmakuPopupControllerDefines_h */
