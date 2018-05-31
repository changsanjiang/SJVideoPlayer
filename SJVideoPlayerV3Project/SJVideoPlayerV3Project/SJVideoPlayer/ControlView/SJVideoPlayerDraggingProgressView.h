//
//  SJVideoPlayerDraggingProgressView.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerDraggingProgressViewStyle) {
    SJVideoPlayerDraggingProgressViewStyleArrowProgress,
    SJVideoPlayerDraggingProgressViewStylePreviewProgress,
};

@interface SJVideoPlayerDraggingProgressView : UIView

@property (nonatomic, readwrite) SJVideoPlayerDraggingProgressViewStyle style;

@property (nonatomic, readwrite) float shiftProgress;

@property (nonatomic, readwrite) float playProgress;

- (void)setTimeShiftStr:(NSString *)shiftTimeStr;
- (void)setTimeShiftStr:(NSString *)shiftTimeStr totalTimeStr:(NSString *)totalTimeStr;
- (void)setPreviewImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
