//
//  SJLightweightControlLayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>

/**
 轻量级的控制层
 */
@interface SJLightweightControlLayer : NSObject<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

- (void)dismissFilmEditingViewCompletion:(void(^ __nullable)(SJLightweightControlLayer *layer))completion;

@end
