//
//  SJSlider.h
//  dancebaby
//
//  Created by BlueDancer on 2017/6/12.
//  Copyright © 2017年 hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJSliderDelegate;

@interface SJSlider : UIView

/*!
 *  轨道
 */
@property (nonatomic, strong, readonly) UIImageView *trackImageView;

/*!
 *  走过的痕迹
 */
@property (nonatomic, strong, readonly) UIImageView *traceImageView;

/*!
 *  拇指
 */
@property (nonatomic, strong, readonly) UIImageView *thumbImageView;

/*!
 *  borderColor
 *  default is lightGrayColor.
 *  if you don't want it, you can set it to clearColor.
 */
@property (nonatomic, strong, readwrite) UIColor *borderColor;

/*!
 *  borderWidth
 *  default is 0.4.
 */
@property (nonatomic, assign, readwrite) CGFloat borderWidth;

/*!
 *  当前进度值
 */
@property (nonatomic, assign, readwrite) CGFloat value;

/*!
 *  设置轨道高度. default is 8.0;
 */
@property (nonatomic, assign, readwrite) CGFloat trackHeight;

/*!
 *  最小值. default is 0.0;
 */
@property (nonatomic, assign, readwrite) CGFloat minValue;

/*!
 *  最大值. default is 1.0;
 */
@property (nonatomic, assign, readwrite) CGFloat maxValue;

@property (nonatomic, weak) id <SJSliderDelegate>delegate;

/*!
 *  触动手势
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;

/*!
 *  slider是否被拖拽
 */
@property (nonatomic, assign, readonly) BOOL isDragging;

@end



// MARK: 缓冲


@interface SJSlider (SJBufferProgress)

/*!
 *  开启缓冲进度. default is NO.
 */
@property (nonatomic, assign, readwrite) BOOL enableBufferProgress;

/*!
 *  缓冲进度颜色. default is grayColor
 */
@property (nonatomic, strong, readwrite) UIColor *bufferProgressColor;

/*!
 *  缓冲进度
 */
@property (nonatomic, assign, readwrite) CGFloat bufferProgress;

@end




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
