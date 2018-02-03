//
//  SJVideoPlayerDraggingProgressView.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerAssetCarrier, SJOrentationObserver;

@interface SJVideoPlayerDraggingProgressView : UIView

- (instancetype)initWithOrentationObserver:(__weak SJOrentationObserver *)orentationObserver;

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

@property (nonatomic, readwrite) float progress;

@end

NS_ASSUME_NONNULL_END
