//
//  SJBarrageQueueController.h
//  Pods
//
//  Created by BlueDancer on 2019/11/12.
//

#import "SJBarrageQueueControllerDefines.h"
#import <UIKit/UIKit.h>
@class SJBarrageLineConfiguration;

NS_ASSUME_NONNULL_BEGIN
@interface SJBarrageQueueController : NSObject<SJBarrageQueueController>
- (instancetype)initWithLines:(NSUInteger)lines;
- (nullable SJBarrageLineConfiguration *)configurationAtIndex:(NSInteger)idx;
- (void)updateForConfigurations;

@property (nonatomic, getter=isDisabled) BOOL disabled;

- (void)enqueue:(id<SJBarrageItem>)barrage;
- (void)emptyQueue;
- (void)removeDisplayedBarrages;
- (void)removeAll;

@property (nonatomic, readonly, getter=isPaused) BOOL paused;
- (void)pause;
- (void)resume;

- (UIView *)view;

- (id<SJBarrageQueueControllerObserver>)getObserver;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end


@interface SJBarrageLineConfiguration : NSObject
///
/// 弹幕移动速率
///
///         default value 1.0
///
@property (nonatomic) CGFloat rate;

///
/// 顶部间距
///
///         default value is 3.0
///
@property (nonatomic) CGFloat topMargin;

///
/// item的间距
///
///         default value is 38.0
///
@property (nonatomic) CGFloat itemMargin;

///
/// 行高
///
///         default value is 26.0
///
@property (nonatomic) CGFloat height;
@end
NS_ASSUME_NONNULL_END
