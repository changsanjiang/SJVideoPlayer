//
//  SJVideoPlayerFilmEditingControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShareItem;

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingViewTag) {
    SJVideoPlayerFilmEditingViewTag_Screenshot,
    SJVideoPlayerFilmEditingViewTag_Export,
};

@interface SJVideoPlayerFilmEditingControlView : UIView

@property (nonatomic, copy, nullable) UIImage *(^getVideoScreenshot)(SJVideoPlayerFilmEditingControlView *view);
@property (nonatomic, copy, nullable) void(^exit)(SJVideoPlayerFilmEditingControlView *view);
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *filmEditingResultShareItems;
@property (nonatomic, strong, nullable) UIImage *screenshotBtnImage;
@property (nonatomic, strong, nullable) UIImage *exportBtnImage;
@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic, strong, nullable) UIImage *recordEndBtnImage;
@property (nonatomic, strong, nullable) NSString *recordTipsText;

@end
NS_ASSUME_NONNULL_END
