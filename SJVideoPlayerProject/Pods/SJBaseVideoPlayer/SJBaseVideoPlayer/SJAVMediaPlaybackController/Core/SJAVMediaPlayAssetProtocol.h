//
//  SJAVMediaPlayAssetProtocol.h
//  Pods
//
//  Created by 畅三江 on 2018/7/2.
//

#ifndef SJAVMediaPlayAssetProtocol_h
#define SJAVMediaPlayAssetProtocol_h

#import <AVFoundation/AVFoundation.h>

@protocol SJAVMediaPlayAssetProtocol<NSObject>

@property (nonatomic, strong, readonly, nullable) AVURLAsset *URLAsset;
@property (nonatomic, strong, readonly, nullable) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly, nullable) AVPlayer *player;

@end

#endif /* SJAVMediaPlayAssetProtocol_h */
