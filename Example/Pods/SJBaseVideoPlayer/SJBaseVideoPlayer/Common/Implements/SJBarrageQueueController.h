//
//  SJBarrageQueueController.h
//  Pods
//
//  Created by 畅三江 on 2019/11/12.
//

#import "SJBarrageQueueControllerDefines.h"
#import <UIKit/UIKit.h>
@protocol SJBarrageLineConfigurationDelegate;
@class SJBarrageLineConfiguration;

NS_ASSUME_NONNULL_BEGIN
@interface SJBarrageQueueController : NSObject<SJBarrageQueueController>
- (instancetype)initWithNumberOfLines:(NSUInteger)numberOfLines;

@property (nonatomic) NSInteger numberOfLines;

@property (nonatomic, strong, readonly) SJBarrageLineConfiguration *configuration;

- (void)reloadConfiguration; ///< 当配置修改后, 请调用该方法来刷新

@property (nonatomic, getter=isDisabled) BOOL disabled;

- (void)enqueue:(id<SJBarrageItem>)barrage;
- (void)emptyQueue;
- (void)removeDisplayedBarrages;
- (void)removeAll;

@property (nonatomic, readonly, getter=isPaused) BOOL paused;
- (void)pause;
- (void)resume;

- (id<SJBarrageQueueControllerObserver>)getObserver;

@property (nonatomic, strong, readonly) __kindof UIView *view;
@property (nonatomic, readonly) NSInteger queueSize; ///< 未显示的弹幕数量

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end


@interface SJBarrageLineConfiguration : NSObject

@property (nonatomic, weak, nullable) id<SJBarrageLineConfigurationDelegate> delegate;

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


@protocol SJBarrageLineConfigurationDelegate <NSObject>
@optional
/// 移动速率
- (CGFloat)barrageLineConfiguration:(SJBarrageLineConfiguration *)configuration rateForLineAtIndex:(NSInteger)index;
/// 弹幕之间的间距
- (CGFloat)barrageLineConfiguration:(SJBarrageLineConfiguration *)configuration itemSpacingForLineAtIndex:(NSInteger)index;

/// 顶部外间距
- (CGFloat)barrageLineConfiguration:(SJBarrageLineConfiguration *)configuration topMarginForLineAtIndex:(NSInteger)index;
/// 行高
- (CGFloat)barrageLineConfiguration:(SJBarrageLineConfiguration *)configuration heightForLineAtIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
