//
//  SJSlider.h
//  Pods-SJSlider_Example
//
//  Created by BlueDancer on 2018/5/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJSliderDelegate;

@interface SJSlider : UIView

@property (nonatomic, weak) id <SJSliderDelegate>delegate;

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
 *  If you do not set the image, it will not display.
 *
 *  拇指, 不设置它, 将不会创建.
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

/*!
 *  The state of dragging.
 *
 *  是否在拖拽.
 */
@property (nonatomic, assign, readonly) BOOL isDragging;

@end



#pragma mark - Border
@interface SJSlider (BorderLine)

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
@interface SJSlider (SJBufferProgress)

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


@protocol SJSliderDelegate <NSObject>

@optional

/*!
 *  开始滑动
 */
- (void)sliderWillBeginDragging:(SJSlider *)slider;

/*!
 *  正在滑动
 */
- (void)sliderDidDrag:(SJSlider *)slider;

/*!
 *  滑动完成
 */
- (void)sliderDidEndDragging:(SJSlider *)slider;

@end
NS_ASSUME_NONNULL_END
