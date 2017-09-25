//
//  SJVideoPlayerAssetCarrier.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVURLAsset, AVPlayer, AVPlayerItem;

@interface SJVideoPlayerAssetCarrier : NSObject

- (instancetype)initWithAssetURL:(NSURL *)assetURL;

@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) NSURL *assetURL;

@end
