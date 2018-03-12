//
//  SJVideoPlayerFilmEditingRecordView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerFilmEditingRecordView : UIView

@property (nonatomic, readonly) short currentTime; // sec.
@property (nonatomic, strong, nullable) NSString *waitingForRecordingTipsText;
@property (nonatomic, strong, nullable) NSString *tipsText;
@property (nonatomic, strong, nullable) UIImage *recordEndBtnImage;
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;

@property (nonatomic, copy, nullable) void(^clickedCancleBtnExeBlock)(SJVideoPlayerFilmEditingRecordView *view);
@property (nonatomic, copy, nullable) void(^clickedCompleteBtnExeBlock)(SJVideoPlayerFilmEditingRecordView *view);

- (void)start;
- (void)stop;

@end
NS_ASSUME_NONNULL_END
