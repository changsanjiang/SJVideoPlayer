//
//  SJVideoPlayerFilmEditingResultView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJFilmEditingResultShareItem;

@interface SJVideoPlayerFilmEditingResultView : UIView

@property (nonatomic, strong, nullable) NSString *cancelBtnTitle;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, copy, nullable) void(^clickedCancleBtn)(SJVideoPlayerFilmEditingResultView *view);
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *filmEditingResultShareItems;

- (void)startAnimation;

@end
NS_ASSUME_NONNULL_END
