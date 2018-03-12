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

@property (nonatomic, strong, nullable) NSString *waitingForRecordingTipsText;
@property (nonatomic, strong, nullable) NSString *tipsText;
@property (nonatomic, strong, nullable) UIImage *recordEndBtnImage;
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;

@property (nonatomic, copy, nullable) void(^exit)(SJVideoPlayerFilmEditingRecordView *view);
@property (nonatomic, copy, nullable) void(^completeExeBlock)(SJVideoPlayerFilmEditingRecordView *view, short duration);

- (void)startRecord;

@end
NS_ASSUME_NONNULL_END
