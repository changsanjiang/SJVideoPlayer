//
//  SJVideoPlayerFilmEditingControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShare;

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingViewTag) {
    SJVideoPlayerFilmEditingViewTag_Screenshot,
    SJVideoPlayerFilmEditingViewTag_Export,
};

@interface SJVideoPlayerFilmEditingControlView : UIView

@property (nonatomic, strong, nullable) SJFilmEditingResultShare *resultShare;
@property (nonatomic, copy, nullable) UIImage *(^getVideoScreenshot)(SJVideoPlayerFilmEditingControlView *view);
@property (nonatomic, copy, nullable) void(^exit)(SJVideoPlayerFilmEditingControlView *view);
@property (nonatomic, copy, nullable) void(^startRecordingExeBlock)(SJVideoPlayerFilmEditingControlView *view);


#pragma mark - common
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic, strong, nullable) UIImage *screenshotBtnImage;
@property (nonatomic, strong, nullable) UIImage *exportBtnImage;

#pragma mark - record
- (void)completeRecording;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, copy, nullable) void(^recordCompleteExeBlock)(SJVideoPlayerFilmEditingControlView *view, short duration);
@property (nonatomic, readwrite) float recordedVideoExportProgress;
@property (nonatomic, readwrite) BOOL exportFailed;
@property (nonatomic, strong, nullable) NSURL *exportedVideoURL;
@property (nonatomic, strong, nullable) UIImage *recordEndBtnImage;
@property (nonatomic, strong, nullable) NSString *waitingForRecordingTipsText;
@property (nonatomic, strong, nullable) NSString *recordTipsText;
@property (nonatomic, strong, nullable) NSString *uploadingPrompt;
@property (nonatomic, strong, nullable) NSString *exportingPrompt;
@property (nonatomic, strong, nullable) NSString *operationFailedPrompt;

@end
NS_ASSUME_NONNULL_END
