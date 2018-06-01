//
//  SJFilmEditingControlLayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"
#import "SJFilmEditingStatus.h"
#import "SJFilmEditingSettings.h"
#import "SJVideoPlayerFilmEditingConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJFilmEditingControlLayer : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

- (void)exitControlLayer;
- (void)restartControlLayer;

#pragma mark

@property (nonatomic, weak, nullable) id <SJVideoPlayerFilmEditingResultUpload> uploader;
@property (nonatomic, weak, nullable) id <SJFilmEditingControlLayerDelegate> delegate;

#pragma mark - operation
@property (nonatomic, readonly) SJVideoPlayerFilmEditingOperation currentOperation; // user selected operation.

#pragma mark -
@property (nonatomic, copy, readonly) void(^update)(void(^block)(SJFilmEditingSettings *settings));
@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingConfig *config;
@property (nonatomic, readonly) SJFilmEditingStatus status;
- (void)pause;      // `filmEditingControlLayer:statusChanged:` will be called.
- (void)resume;     // `filmEditingControlLayer:statusChanged:` will be called.
- (void)cancel;     // `filmEditingControlLayer:statusChanged:` will be called.
- (void)finalize;   // `filmEditingControlLayer:statusChanged:` will be called.

@end
NS_ASSUME_NONNULL_END
