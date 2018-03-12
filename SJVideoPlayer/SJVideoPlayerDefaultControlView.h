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

@protocol SJVideoPlayerDefaultControlViewDelegate;

@interface SJVideoPlayerDefaultControlView : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerDefaultControlViewDelegate> delegate;

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, strong, readwrite, nullable) SJFilmEditingResultShare *filmEditingResultShare;

@property (nonatomic, readwrite) BOOL generatePreviewImages;

@property (nonatomic, readwrite) BOOL disableNetworkStatusChangePrompt; // default is no.

@end

@protocol SJVideoPlayerDefaultControlViewDelegate <NSObject>

@required
- (void)clickedBackBtnOnControlView:(SJVideoPlayerDefaultControlView *)controlView;

@end

NS_ASSUME_NONNULL_END
