//
//  SJEdgeControlLayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>

@protocol SJEdgeControlLayerDelegate;
@class SJVideoPlayerMoreSetting, SJFilmEditingResultShare;

NS_ASSUME_NONNULL_BEGIN

@interface SJEdgeControlLayer : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

- (void)restartControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;

- (void)exitControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;

@property (nonatomic, weak) id <SJEdgeControlLayerDelegate> delegate;



#pragma mark
@property (nonatomic, strong, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, strong, nullable) SJFilmEditingResultShare *filmEditingResultShare;

@property (nonatomic) BOOL generatePreviewImages;

@property (nonatomic) BOOL enableFilmEditing;

@property (nonatomic) BOOL disableNetworkStatusChangePrompt;

@end

@protocol SJEdgeControlLayerDelegate <NSObject>

@optional
  
/// 返回按钮被点击
- (void)clickedBackBtnOnControlLayer:(SJEdgeControlLayer *)controlLayer;

/// 右侧按钮被点击
- (void)clickedFilmEditingBtnOnControlLayer:(SJEdgeControlLayer *)controlLayer;
@end

NS_ASSUME_NONNULL_END
