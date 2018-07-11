//
//  SJPlayAssetProtocol.h
//  Pods
//
//  Created by 畅三江 on 2018/7/2.
//

#ifndef SJPlayAssetProtocol_h
#define SJPlayAssetProtocol_h

#import <AVFoundation/AVFoundation.h>

@protocol SJPlayAsset<NSObject>

@property (nonatomic, strong, readonly, nullable) AVURLAsset *URLAsset;
@property (nonatomic, strong, readonly, nullable) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly, nullable) AVPlayer *player;

@end

#endif /* SJPlayAssetProtocol_h */
