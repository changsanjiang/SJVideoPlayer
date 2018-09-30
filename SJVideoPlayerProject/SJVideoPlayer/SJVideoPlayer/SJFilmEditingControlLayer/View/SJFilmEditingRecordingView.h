//
//  SJFilmEditingRecordingView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJFilmEditingStatus.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingRecordingView : UIView
@property (nonatomic, readonly) SJFilmEditingStatus status;
@property (nonatomic, readonly) short duration; // sec.
@property (nonatomic, strong, nullable) NSString *waitingForRecordingPromptText;
@property (nonatomic, strong, nullable) NSString *finishRecordingPromptText;
@property (nonatomic, strong, nullable) UIImage *finishRecordingBtnImage;
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;


@property (nonatomic, copy, nullable) void(^clickedCancleBtnExeBlock)(SJFilmEditingRecordingView *view);
@property (nonatomic, copy, nullable) void(^clickedCompleteBtnExeBlock)(SJFilmEditingRecordingView *view);

- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;
- (void)finished;

@property (nonatomic, copy, nullable) void(^statusChangedExeBlock)(__kindof UIView *view, SJFilmEditingStatus status);

@end
NS_ASSUME_NONNULL_END
