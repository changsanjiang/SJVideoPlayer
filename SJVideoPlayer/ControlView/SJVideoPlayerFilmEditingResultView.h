//
//  SJVideoPlayerFilmEditingResultView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShare;

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingResultViewType) {
    SJVideoPlayerFilmEditingResultViewType_Screenshot,
    SJVideoPlayerFilmEditingResultViewType_Video,
};

@interface SJVideoPlayerFilmEditingResultView : UIView

- (instancetype)initWithType:(SJVideoPlayerFilmEditingResultViewType)type;

@property (nonatomic, readonly) SJVideoPlayerFilmEditingResultViewType type;
@property (nonatomic, strong, nullable) SJFilmEditingResultShare *resultShare;
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic, strong, nullable) UIImage *image;

@property (nonatomic, strong, nullable) NSString *uploadingPrompt;
@property (nonatomic, strong, nullable) NSString *exportingPrompt;
@property (nonatomic, strong, nullable) NSString *operationFailedPrompt;
#pragma mark - record
@property (nonatomic, readwrite) BOOL exportFailed;
@property (nonatomic, readwrite) float recordedVideoExportProgress;
@property (nonatomic, strong, nullable) NSURL *exportedVideoURL;
- (void)showResultWithCompletion:(void (^ __nullable)(void))block;

@end
NS_ASSUME_NONNULL_END
