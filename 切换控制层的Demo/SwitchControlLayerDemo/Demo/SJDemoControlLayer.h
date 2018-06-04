//
//  SJDemoControlLayer.h
//  SwitchControlLayerDemo
//
//  Created by BlueDancer on 2018/6/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>

@interface SJDemoControlLayer : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

- (void)restartControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;

- (void)exitControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler;

@end
