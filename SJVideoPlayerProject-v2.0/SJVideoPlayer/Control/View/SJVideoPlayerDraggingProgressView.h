//
//  SJVideoPlayerDraggingProgressView.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class SJSlider;

@interface SJVideoPlayerDraggingProgressView : SJVideoPlayerBaseView

@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) SJSlider *progressSlider;

@end

NS_ASSUME_NONNULL_END
