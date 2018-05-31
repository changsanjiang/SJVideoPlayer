//
//  SJVideoPlayerFilmEditingCommonHeader.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerFilmEditingCommonHeader_h
#define SJVideoPlayerFilmEditingCommonHeader_h

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingStatus.h"

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerFilmEditingControlView, SJFilmEditingResultShareItem, SJVideoPlayerURLAsset;

@protocol SJVideoPlayerFilmEditingControlViewDataSource, SJVideoPlayerFilmEditingControlViewDelegate, SJVideoPlayerFilmEditingPromptResource, SJVideoPlayerFilmEditing, SJVideoPlayerFilmEditingResultUpload, SJVideoPlayerFilmEditingResult;



typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingOperation) {
    SJVideoPlayerFilmEditingOperation_Screenshot,
    SJVideoPlayerFilmEditingOperation_Export,
    SJVideoPlayerFilmEditingOperation_GIF,
};


@protocol SJVideoPlayerFilmEditingControlViewDataSource <NSObject>

- (UIImage *)playerScreenshot;

- (id<SJVideoPlayerFilmEditing>)filmEditing;

- (NSArray<SJFilmEditingResultShareItem *> *)resultShareItems;

- (SJVideoPlayerURLAsset *)currentPalyAsset;

- (BOOL)resultNeedUpload;

- (BOOL)shouldStartWhenUserSelectedAnOperation:(SJVideoPlayerFilmEditingOperation)selectedOperation;

- (CGFloat)operationContainerViewRightOffset;

@end





@protocol SJVideoPlayerFilmEditingControlViewDelegate <NSObject>

- (void)filmEditingControlView:(SJVideoPlayerFilmEditingControlView *)filmEditingControlView statusChanged:(SJVideoPlayerFilmEditingStatus)status;

/// 用户点击空白区域
- (void)userTappedBlankAreaAtFilmEditingControlView:(SJVideoPlayerFilmEditingControlView *)filmEditingControlView;

/// 用户选择了其中一个操作 --> [截屏/导出视频/导出GIF]
- (void)filmEditingControlView:(SJVideoPlayerFilmEditingControlView *)filmEditingControlView userSelectedOperation:(SJVideoPlayerFilmEditingOperation)operation;

- (void)filmEditingControlView:(SJVideoPlayerFilmEditingControlView *)filmEditingControlView userClickedResultShareItem:(SJFilmEditingResultShareItem *)item result:(id<SJVideoPlayerFilmEditingResult>)result;

@end






@protocol SJVideoPlayerFilmEditingPromptResource <NSObject>
@property (nonatomic, strong, readonly) UIImage *exportBtnImage;
@property (nonatomic, strong, readonly) UIImage *screenshotBtnImage;
@property (nonatomic, strong, readonly) NSString *cancelBtnTitle;
@property (nonatomic, strong, readonly) NSString *waitingForRecordingPromptText;
@property (nonatomic, strong, readonly) NSString *recordPromptText;
@property (nonatomic, strong, readonly) UIImage *recordEndBtnImage;
@property (nonatomic, strong, readonly) NSString *uploadingPrompt;
@property (nonatomic, strong, readonly) NSString *uploadSuccessfullyPrompt;
@property (nonatomic, strong, readonly) NSString *exportingPrompt;
@property (nonatomic, strong, readonly) NSString *exportSuccessfullyPrompt;
@property (nonatomic, strong, readonly) NSString *operationFailedPrompt;
@property (nonatomic, strong, readonly) UIImage *gifBtnImage;
@end






@protocol SJVideoPlayerFilmEditing <NSObject>

- (NSTimeInterval)currentTime;

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(id<SJVideoPlayerFilmEditing> filmEditing, float progress))progressBlock
                 completion:(void(^)(id<SJVideoPlayerFilmEditing> filmEditing, NSURL *fileURL, UIImage *thumbnailImage))completion
                    failure:(void(^)(id<SJVideoPlayerFilmEditing> filmEditing, NSError *error))failure;
- (void)cancelExportOperation;

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                        progress:(void(^)(id<SJVideoPlayerFilmEditing> filmEditing, float progress))progressBlock
                      completion:(void(^)(id<SJVideoPlayerFilmEditing> filmEditing, UIImage *imageGIF, UIImage *thumbnailImage, NSURL *filePath))completion
                         failure:(void(^)(id<SJVideoPlayerFilmEditing> filmEditing, NSError *error))failure;
- (void)cancelGenerateGIFOperation;

@end







@protocol SJVideoPlayerFilmEditingResult <NSObject>
@property (nonatomic) SJVideoPlayerFilmEditingOperation operation;
@property (nonatomic, strong, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, nullable) NSURL *fileURL;
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *currentPlayAsset;
- (NSData * __nullable)data;
@end



@protocol SJVideoPlayerFilmEditingResultUpload <NSObject>

- (void)upload:(id<SJVideoPlayerFilmEditingResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure;

- (void)cancelUpload:(id<SJVideoPlayerFilmEditingResult>)result;

@end

NS_ASSUME_NONNULL_END

#endif /* SJVideoPlayerFilmEditingCommonHeader_h */
