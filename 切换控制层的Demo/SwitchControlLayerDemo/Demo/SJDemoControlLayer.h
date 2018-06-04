//
//  SJDemoControlLayer.h
//  SwitchControlLayerDemo
//
//  Created by BlueDancer on 2018/6/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>

@protocol SJDemoControlLayerDelegate;

@interface SJDemoControlLayer : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

- (void)restartControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;

- (void)exitControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;

@property (nonatomic, weak) id <SJDemoControlLayerDelegate> delegate;

@end

@protocol SJDemoControlLayerDelegate <NSObject>

@optional
- (void)clickedFilmEditingBtnOnDemoControlLayer:(SJDemoControlLayer *)controlLayer;

@end
