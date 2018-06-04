//
//  SJFilmEditingGenerateGIFView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJFilmEditingStatus.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingGenerateGIFView : UIView
@property (nonatomic, readonly) SJFilmEditingStatus status;
@property (nonatomic, readonly) int maxDuration; // sec. 8s.
@property (nonatomic, readonly) int countDown;
@property (nonatomic, readonly) int duration;


@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic, strong, nullable) NSString *waitingForRecordingPromptText;
@property (nonatomic, strong, nullable) NSString *finishRecordingPromptText;
@property (nonatomic, strong, nullable) UIImage *finishRecordingBtnImage;

@property (nonatomic, copy, nullable) void(^clickedCancleBtnExeBlock)(SJFilmEditingGenerateGIFView *view);
@property (nonatomic, copy, nullable) void(^clickedCompleteBtnExeBlock)(SJFilmEditingGenerateGIFView *view);

- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;
- (void)finished;

@property (nonatomic, copy, nullable) void(^statusChangedExeBlock)(__kindof UIView *view, SJFilmEditingStatus status);

@end
NS_ASSUME_NONNULL_END
