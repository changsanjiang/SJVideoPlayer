//
//  SJVideoPlayerDefaultControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>

@class SJVideoPlayer, SJVideoPlayerMoreSetting, SJFilmEditingResultShare;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerDefaultControlView : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, strong, readwrite, nullable) SJFilmEditingResultShare *filmEditingResultShare;

@property (nonatomic, readwrite) BOOL generatePreviewImages;

@property (nonatomic, readwrite) BOOL enableFilmEditing;

- (void)dismissFilmEditingViewCompletion:(void(^ __nullable)(SJVideoPlayerDefaultControlView *view))completion;

@end

NS_ASSUME_NONNULL_END
