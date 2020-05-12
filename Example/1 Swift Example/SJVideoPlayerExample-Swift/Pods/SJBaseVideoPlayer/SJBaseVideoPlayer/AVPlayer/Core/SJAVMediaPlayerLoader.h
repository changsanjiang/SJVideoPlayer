//
//  SJAVMediaPlayerLoader.h
//  Pods
//
//  Created by 畅三江 on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerURLAsset.h"
#import "SJAVMediaPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayerLoader : NSObject

+ (nullable SJAVMediaPlayer *)loadPlayerForMedia:(SJVideoPlayerURLAsset *)media;

+ (void)clearPlayerForMedia:(SJVideoPlayerURLAsset *)media;

@end
NS_ASSUME_NONNULL_END
