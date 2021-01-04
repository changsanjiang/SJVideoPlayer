//
//  SJProgressSlider.h
//  Pods-SJProgressSlider_Example
//
//  Created by 畅三江 on 2017/11/20.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJProgressSliderDelegate;

@interface SJProgressSlider : UIView

@property (nonatomic, weak) id <SJProgressSliderDelegate>delegate;

/// Default is YES. 是否切园角. 默认YES
@property (nonatomic, getter=isRound) BOOL round;

/// Track height. default is 8.0. 轨道高度
@property (nonatomic) CGFloat trackHeight;

/*!
 *  this is view, If you don't want to set image, You can set the background color.
 *
 *  轨道, 你可以设置图片或者将他当做`view`, 设置背景颜色来使用. 以下`trace` & `thumb` 相同.
 */
@property (nonatomic, strong, readonly) UIImageView *trackImageView;

/*!
 *  this is view, If you don't want to set image, You can set the background color.
 *
 *  走过的痕迹.
 */
@property (nonatomic, strong, readonly) UIImageView *traceImageView;

/*!
 *  拇指
 */
@property (nonatomic, strong, readonly) UIImageView *thumbImageView;


- (void)setThumbCornerRadius:(CGFloat)thumbCornerRadius
                        size:(CGSize)size;

- (void)setThumbCornerRadius:(CGFloat)thumbCornerRadius
                        size:(CGSize)size
        thumbBackgroundColor:(UIColor *)thumbBackgroundColor;

/*!
 *  current Value
 */
@property (nonatomic) CGFloat value;
- (void)setValue:(CGFloat)value animated:(BOOL)animated;
@property (nonatomic) CGFloat animaMaxDuration; // default is 0.5.

/*!
 *  default is 0.0;
 */
@property (nonatomic) CGFloat minValue;

/*!
 *  default is 1.0;
 */
@property (nonatomic) CGFloat maxValue;

/*!
 *  default is 0;
 */
@property (nonatomic) CGFloat expand;

/*!
 *  default is 0.382;
 *  0...1
 */
@property (nonatomic) float thumbOutsideSpace;

/*!
 *  If you don't want to use this gesture, you can disable it
 *  pan.enable = NO.
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;

/// 点击跳转的手势
/// - 当你想点击跳转时, 需要开启手势
/// - 默认是关闭, 即 tap.enabled = NO;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tap;
@property (nonatomic, copy, nullable) void(^tappedExeBlock)(SJProgressSlider *slider, CGFloat location);

/*!
 *  The state of dragging.
 *
 *  是否在拖拽.
 */
@property (nonatomic, assign, readonly) BOOL isDragging;
- (void)cancelDragging; // 取消拖拽

/// 是否加载中
/// - 如果是YES, 将会在拇指上显示菊花圈圈(前提是设置了拇指thumb)
@property (nonatomic) BOOL isLoading;

/// 菊花圈圈的线颜色
/// - 默认是黑色
@property (nonatomic, strong) UIColor *loadingColor;

@end


#pragma mark - Prompt

@interface SJProgressSlider (Prompt)

@property (nonatomic, strong, readonly) UILabel *promptLabel;

/// default is 4.0
@property (nonatomic) CGFloat promptSpacing;

@end



#pragma mark - Border
@interface SJProgressSlider (Border)

/*!
 *  default is NO.
 */
@property (nonatomic) BOOL showsBorder;

/*!
 *  borderColor
 *  default is lightGrayColor.
 */
@property (null_resettable, nonatomic, strong) UIColor *borderColor;

/*!
 *  borderWidth
 *  default is 0.4.
 */
@property (nonatomic) CGFloat borderWidth;

@end



#pragma mark - Buffer

@interface SJProgressSlider (Buffer)

/*!
 *  开启缓冲进度. default is NO.
 */
@property (nonatomic) BOOL showsBufferProgress;

/*!
 *  缓冲进度颜色. default is grayColor
 */
@property (nonatomic, strong, null_resettable) UIColor *bufferProgressColor;

/*!
 *  缓冲进度
 *
 *  0...1
 */
@property (nonatomic) CGFloat bufferProgress;

@end


#pragma mark - Stop Node

@interface SJProgressSlider (StopNode)

@property (nonatomic) BOOL showsStopNode;

@property (nonatomic, strong, null_resettable) UIView *stopNodeView;

/// 0..1
@property (nonatomic) CGFloat stopNodeLocation;

- (void)setStopNodeViewCornerRadius:(CGFloat)cornerRadius size:(CGSize)size;
- (void)setStopNodeViewCornerRadius:(CGFloat)cornerRadius size:(CGSize)size backgroundColor:(UIColor *)backgroundColor;
@end


#pragma mark - Delegate


@protocol SJProgressSliderDelegate <NSObject>

@optional

/*!
 *  开始滑动
 */
- (void)sliderWillBeginDragging:(SJProgressSlider *)slider;


- (void)slider:(SJProgressSlider *)slider valueDidChange:(CGFloat)value;

/*!
 *  滑动完成
 */
- (void)sliderDidEndDragging:(SJProgressSlider *)slider;



- (void)sliderDidDrag:(SJProgressSlider *)slider __deprecated_msg("use `slider:valueDidChange:`");
@end
NS_ASSUME_NONNULL_END
