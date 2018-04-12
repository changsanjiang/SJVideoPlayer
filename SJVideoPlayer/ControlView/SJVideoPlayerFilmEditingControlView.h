//
//  SJVideoPlayerFilmEditingControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingStatus.h"

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShare;

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingOperation) {
    SJVideoPlayerFilmEditingOperation_Screenshot,
    SJVideoPlayerFilmEditingOperation_Export,
    SJVideoPlayerFilmEditingOperation_GIF,
};

@protocol SJVideoPlayerFilmEditingControlViewDataSource, SJVideoPlayerFilmEditingControlViewDelegate, SJVideoPlayerFilmEditingControlViewResource;




@interface SJVideoPlayerFilmEditingControlView : UIView<SJVideoPlayerExportVideoDelegate>

@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingControlViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingControlViewDelegate> delegate;
@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingControlViewResource> resource;


@property (nonatomic, readonly) SJVideoPlayerFilmEditingOperation currentOperation; // user selected operation.

@property (nonatomic) BOOL disableScreenshot;   // default is NO
@property (nonatomic) BOOL disableRecord;       // default is NO
@property (nonatomic) BOOL disableGIF;          // default is NO

@property (nonatomic, strong, nullable) SJFilmEditingResultShare *resultShare;

#pragma mark -
@property (nonatomic, strong, nullable) NSURL *exportedFileURL;
@property (nonatomic, readwrite) float exportProgress;
@property (nonatomic, readwrite) BOOL exportFailed;


#pragma mark -
@property (nonatomic, readonly) SJVideoPlayerFilmEditingStatus status;
- (void)pause;      // call delegate method `filmEditingControlView:statusChanged:`
- (void)resume;     // call delegate method `filmEditingControlView:statusChanged:`
- (void)cancel;     // call delegate method `filmEditingControlView:statusChanged:`
- (void)finalize;   // call delegate method `filmEditingControlView:statusChanged:`

#pragma mark - record
@property (nonatomic, copy, nullable) void(^startRecordingExeBlock)(SJVideoPlayerFilmEditingControlView *view);
@property (nonatomic, copy, nullable) void(^recordCompleteExeBlock)(SJVideoPlayerFilmEditingControlView *view, short duration);

@end

@protocol SJVideoPlayerFilmEditingControlViewDataSource <NSObject>

- (UIImage *)playerScreenshot;

@end


@protocol SJVideoPlayerFilmEditingControlViewDelegate <NSObject>

- (void)filmEditingControlView:(SJVideoPlayerFilmEditingControlView *)filmEditingControlView statusChanged:(SJVideoPlayerFilmEditingStatus)status;

/// 用户点击空白区域
- (void)userTappedBlankAreaAtFilmEditingControlView:(SJVideoPlayerFilmEditingControlView *)filmEditingControlView;

/// 用户选择其中一个操作 --> [截屏/导出视频/导出GIF]
- (void)filmEditingControlView:(SJVideoPlayerFilmEditingControlView *)filmEditingControlView userSelectedOperation:(SJVideoPlayerFilmEditingOperation)operation;

@end


@protocol SJVideoPlayerFilmEditingControlViewResource <NSObject>
@property (nonatomic, strong, readonly) UIImage *exportBtnImage;
@property (nonatomic, strong, readonly) UIImage *screenshotBtnImage;
@property (nonatomic, strong, readonly) NSString *cancelBtnTitle;
@property (nonatomic, strong, readonly) NSString *waitingForRecordingPromptText;
@property (nonatomic, strong, readonly) NSString *recordPromptText;
@property (nonatomic, strong, readonly) UIImage *recordEndBtnImage;
@property (nonatomic, strong, readonly) NSString *uploadingPrompt;
@property (nonatomic, strong, readonly) NSString *exportingPrompt;
@property (nonatomic, strong, readonly) NSString *operationFailedPrompt;
@property (nonatomic, strong, readonly) UIImage *gifBtnImage;
@end
NS_ASSUME_NONNULL_END
