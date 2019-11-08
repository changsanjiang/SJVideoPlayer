//
//  SJVideoPlayerDraggingProgressView.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerDraggingProgressViewStyle) {
    SJVideoPlayerDraggingProgressViewStyleArrowProgress,
    SJVideoPlayerDraggingProgressViewStylePreviewProgress,
};

@interface SJVideoPlayerDraggingProgressView : UIView
@property (nonatomic) SJVideoPlayerDraggingProgressViewStyle style;

@property (nonatomic) NSTimeInterval progressTime;
- (void)setMaxValue:(NSTimeInterval)maxValue;
- (void)setCurrentTime:(NSTimeInterval)currentTime;
- (void)setPreviewImage:(UIImage *)image;

- (void)setProgressTimeStr:(NSString *)shiftTimeStr;
- (void)setProgressTimeStr:(NSString *)shiftTimeStr totalTimeStr:(NSString *)totalTimeStr;
@end

NS_ASSUME_NONNULL_END
