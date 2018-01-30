//
//  SJVideoPlayerDraggingProgressView.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerAssetCarrier, SJOrentationObserver;

@interface SJVideoPlayerDraggingProgressView : SJVideoPlayerBaseView

- (instancetype)initWithOrentationObserver:(__weak SJOrentationObserver *)orentationObserver;

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

@property (nonatomic, readwrite) float progress;

@end

NS_ASSUME_NONNULL_END
