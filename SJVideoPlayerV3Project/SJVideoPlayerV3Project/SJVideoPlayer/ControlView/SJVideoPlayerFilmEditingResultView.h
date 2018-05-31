//
//  SJVideoPlayerFilmEditingResultView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShareItem;

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingResultViewType) {
    SJVideoPlayerFilmEditingResultViewType_Screenshot,
    SJVideoPlayerFilmEditingResultViewType_Video,
    SJVideoPlayerFilmEditingResultViewType_GIF,
};


@interface SJVideoPlayerFilmEditingResultView : UIView

- (instancetype)initWithType:(SJVideoPlayerFilmEditingResultViewType)type;

- (void)presentResultViewWithCompletion:(void (^ __nullable)(void))block;
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *shareItems;
@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingPromptResource> resource;

@property (nonatomic, strong, nullable) NSURL *videoURL; // local file
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) float exportProgress;
@property (nonatomic) float uploadProgress;

- (void)exportEndedWithStatus:(BOOL)exportStatus;

- (void)uploadEndedWithStatus:(BOOL)uploadStatus;


@property (nonatomic, copy, nullable) void(^clickedCancelBtnExeBlock)(SJVideoPlayerFilmEditingResultView *view);
@property (nonatomic, copy, nullable) void (^clickedItemExeBlock)(SJVideoPlayerFilmEditingResultView *view, SJFilmEditingResultShareItem * item);

@property (nonatomic, readonly) SJVideoPlayerFilmEditingResultViewType type;

@end

NS_ASSUME_NONNULL_END
