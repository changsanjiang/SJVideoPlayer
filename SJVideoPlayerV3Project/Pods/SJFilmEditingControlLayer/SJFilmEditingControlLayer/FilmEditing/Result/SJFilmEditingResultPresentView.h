//
//  SJFilmEditingResultPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShareItem;

typedef NS_ENUM(NSUInteger, SJFilmEditingResultPresentViewType) {
    SJFilmEditingResultPresentViewType_Screenshot,
    SJFilmEditingResultPresentViewType_Video,
    SJFilmEditingResultPresentViewType_GIF,
};


@interface SJFilmEditingResultPresentView : UIView

- (instancetype)initWithType:(SJFilmEditingResultPresentViewType)type;

- (void)presentResultViewWithCompletion:(void (^ __nullable)(void))block;
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *shareItems;

@property (nonatomic, strong, nullable) NSURL *videoURL; // local file
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) float exportProgress;
@property (nonatomic) float uploadProgress;

- (void)exportEndedWithStatus:(BOOL)exportStatus;

- (void)uploadEndedWithStatus:(BOOL)uploadStatus;


@property (nonatomic, copy, nullable) void(^clickedCancelBtnExeBlock)(SJFilmEditingResultPresentView *view);
@property (nonatomic, copy, nullable) void (^clickedItemExeBlock)(SJFilmEditingResultPresentView *view, SJFilmEditingResultShareItem * item);

@property (nonatomic, readonly) SJFilmEditingResultPresentViewType type;



#pragma mark
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic, strong, nullable) NSString *uploadingPrompt;
@property (nonatomic, strong, nullable) NSString *uploadSuccessfullyPrompt;
@property (nonatomic, strong, nullable) NSString *exportingPrompt;
@property (nonatomic, strong, nullable) NSString *exportSuccessfullyPrompt;
@property (nonatomic, strong, nullable) NSString *operationFailedPrompt;
@end

NS_ASSUME_NONNULL_END
