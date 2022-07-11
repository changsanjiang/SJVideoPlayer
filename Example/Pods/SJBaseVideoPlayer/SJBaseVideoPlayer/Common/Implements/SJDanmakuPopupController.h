//
//  SJDanmakuPopupController.h
//  Pods
//
//  Created by 畅三江 on 2019/11/12.
//

#import "SJDanmakuPopupControllerDefines.h"
#import <UIKit/UIKit.h>
@protocol SJDanmakuTrackConfigurationDelegate;
@class SJDanmakuTrackConfiguration;

NS_ASSUME_NONNULL_BEGIN
@interface SJDanmakuPopupController : NSObject<SJDanmakuPopupController>
- (instancetype)initWithNumberOfTracks:(NSUInteger)numberOfTracks;

@property (nonatomic) NSInteger numberOfTracks;

@property (nonatomic, strong, readonly) SJDanmakuTrackConfiguration *trackConfiguration;

- (void)reloadTrackConfiguration; ///< 当配置修改后, 请调用该方法来刷新

@property (nonatomic, getter=isDisabled) BOOL disabled;

- (void)enqueue:(id<SJDanmakuItem>)item;
- (void)emptyQueue;
- (void)removeDisplayedItems;
- (void)removeAll;

@property (nonatomic, readonly, getter=isPaused) BOOL paused;
- (void)pause;
- (void)resume;

- (id<SJDanmakuPopupControllerObserver>)getObserver;

@property (nonatomic, strong, readonly) __kindof UIView *view;
@property (nonatomic, readonly) NSInteger queueSize; ///< 未显示的弹幕数量

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end


@interface SJDanmakuTrackConfiguration : NSObject

@property (nonatomic, weak, nullable) id<SJDanmakuTrackConfigurationDelegate> delegate;

///
/// 弹幕移动速率
///
///         default value 1.0
///
@property (nonatomic) CGFloat rate;

///
/// 弹幕之间的间距
///
///         default value is 38.0
///
@property (nonatomic) CGFloat itemSpacing;

///
/// 顶部外间距
///
///         default value is 3.0
///
@property (nonatomic) CGFloat topMargin;

///
/// 行高
///
///         default value is 26.0
///
@property (nonatomic) CGFloat height;
@end


@protocol SJDanmakuTrackConfigurationDelegate <NSObject>
@optional
/// 移动速率
- (CGFloat)trackConfiguration:(SJDanmakuTrackConfiguration *)trackConfiguration rateForTrackAtIndex:(NSInteger)index;
/// 弹幕之间的间距
- (CGFloat)trackConfiguration:(SJDanmakuTrackConfiguration *)trackConfiguration itemSpacingForTrackAtIndex:(NSInteger)index;

/// 顶部外间距
- (CGFloat)trackConfiguration:(SJDanmakuTrackConfiguration *)trackConfiguration topMarginForTrackAtIndex:(NSInteger)index;
/// 行高
- (CGFloat)trackConfiguration:(SJDanmakuTrackConfiguration *)trackConfiguration heightForTrackAtIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
