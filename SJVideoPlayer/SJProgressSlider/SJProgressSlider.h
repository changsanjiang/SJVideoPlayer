//
//  SJProgressSlider.h
//  Pods-SJProgressSlider_Example
//
//  Created by BlueDancer on 2018/5/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJProgressSliderDelegate;

@interface SJProgressSlider : UIView

@property (nonatomic, weak) id <SJProgressSliderDelegate>delegate;

/// Defualt is YES. 是否切园角. 默认YES
@property (nonatomic, getter=isRound) BOOL round;

/// Track height. default is 8.0. 轨道高度
@property (nonatomic) CGFloat trackHeight;

/*!
 *  this is view, If you don't want to set up photos, You can set the background color.
 *
 *  轨道, 你可以设置图片或者将他当做`view`, 设置背景颜色来使用. 以下`trace` & `thumb` 相同.
 */
@property (nonatomic, strong, readonly) UIImageView *trackImageView;

/*!
 *  this is view, If you don't want to set up photos, You can set the background color.
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
 *  If you don't want to use this gesture, you can disable it
 *  pan.enable = NO.
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;

/// 点击跳转的手势
/// - 当你想点击跳转时, 需要开启手势
/// - 默认是关闭, 即 tap.enabled = NO;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tap;

/*!
 *  The state of dragging.
 *
 *  是否在拖拽.
 */
@property (nonatomic, assign, readonly) BOOL isDragging;

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
@interface SJProgressSlider (BorderLine)

/*!
 *  visual border line.
 *  default is NO.
 */
@property (nonatomic) BOOL visualBorder;

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
@interface SJProgressSlider (SJBufferProgress)

/*!
 *  开启缓冲进度. default is NO.
 */
@property (nonatomic) BOOL enableBufferProgress;

/*!
 *  缓冲进度颜色. default is grayColor
 */
@property (nonatomic, strong, readwrite) UIColor *bufferProgressColor;

/*!
 *  缓冲进度
 */
@property (nonatomic) CGFloat bufferProgress;

@end



#pragma mark - Delegate


@protocol SJProgressSliderDelegate <NSObject>

@optional

/*!
 *  开始滑动
 */
- (void)sliderWillBeginDragging:(SJProgressSlider *)slider;

/*!
 *  正在滑动
 */
- (void)sliderDidDrag:(SJProgressSlider *)slider;

/*!
 *  滑动完成
 */
- (void)sliderDidEndDragging:(SJProgressSlider *)slider;

@end
NS_ASSUME_NONNULL_END
