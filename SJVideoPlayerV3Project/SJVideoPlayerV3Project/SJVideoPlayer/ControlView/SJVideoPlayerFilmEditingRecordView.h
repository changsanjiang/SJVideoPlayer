//
//  SJVideoPlayerFilmEditingRecordView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingStatus.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerFilmEditingRecordView : UIView
@property (nonatomic, readonly) SJVideoPlayerFilmEditingStatus status;
@property (nonatomic, readonly) short duration; // sec.
@property (nonatomic, strong, nullable) NSString *waitingForRecordingPromptText;
@property (nonatomic, strong, nullable) NSString *recordPromptText;
@property (nonatomic, strong, nullable) UIImage *recordEndBtnImage;
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic) float completeBtnRightOffset;


@property (nonatomic, copy, nullable) void(^clickedCancleBtnExeBlock)(SJVideoPlayerFilmEditingRecordView *view);
@property (nonatomic, copy, nullable) void(^clickedCompleteBtnExeBlock)(SJVideoPlayerFilmEditingRecordView *view);

- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;
- (void)finished;

@property (nonatomic, copy, nullable) void(^statusChangedExeBlock)(__kindof UIView *view, SJVideoPlayerFilmEditingStatus status);

@end
NS_ASSUME_NONNULL_END
