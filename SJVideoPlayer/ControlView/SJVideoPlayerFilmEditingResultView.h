//
//  SJVideoPlayerFilmEditingResultView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShareItem, SJFilmEditingResultUploader;

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingResultViewType) {
    SJVideoPlayerFilmEditingResultViewType_Screenshot,
    SJVideoPlayerFilmEditingResultViewType_Video,
};

@interface SJVideoPlayerFilmEditingResultView : UIView

- (instancetype)initWithType:(SJVideoPlayerFilmEditingResultViewType)type;

@property (nonatomic, readonly) SJVideoPlayerFilmEditingResultViewType type;
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *items;
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic, strong, nullable) UIImage *image;

@property (nonatomic, weak, readwrite) SJFilmEditingResultUploader *uploader;

@property (nonatomic, strong, nullable) NSString *uploadingPrompt;
@property (nonatomic, strong, nullable) NSString *exportingPrompt;
@property (nonatomic, strong, nullable) NSString *operationFailedPrompt;

@property (nonatomic, readwrite) BOOL exportFailed;
@property (nonatomic, readwrite) float recordedVideoExportProgress;
- (void)showResultWithCompletion:(void (^ __nullable)(void))block;

@property (nonatomic, copy, nullable) void(^clickedCancelBtnExeBlock)(SJVideoPlayerFilmEditingResultView *view);
@property (nonatomic, copy, nullable) void (^clickedItemExeBlock)(SJVideoPlayerFilmEditingResultView *view, SJFilmEditingResultShareItem *item);

@end
NS_ASSUME_NONNULL_END
