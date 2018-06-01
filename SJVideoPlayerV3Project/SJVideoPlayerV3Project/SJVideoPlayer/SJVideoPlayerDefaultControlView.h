//
//  SJVideoPlayerDefaultControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayer.h"

@class SJVideoPlayerMoreSetting, SJFilmEditingResultShare;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerDefaultControlView : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, strong, readwrite, nullable) SJFilmEditingResultShare *filmEditingResultShare;

@property (nonatomic, readwrite) BOOL generatePreviewImages;

@property (nonatomic, readwrite) BOOL enableFilmEditing;
@property (nonatomic, copy, nullable) void(^clickedFilmEditingBtnExeBlock)(SJVideoPlayerDefaultControlView *view);

- (void)dismissFilmEditingViewCompletion:(void(^ __nullable)(SJVideoPlayerDefaultControlView *view))completion;

- (void)exitControlLayer;
- (void)restartControlLayer;

@end

NS_ASSUME_NONNULL_END
