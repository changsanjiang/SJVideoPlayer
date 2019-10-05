//
//  SJAVMediaPlayerLoader.h
//  Pods
//
//  Created by 畅三江 on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "SJAVMediaPlayer.h"
#import "SJVideoPlayerPlaybackControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayerLoader : NSObject

+ (SJAVMediaPlayer *)loadPlayerForMedia:(id<SJMediaModelProtocol>)media;

+ (void)clearPlayerForMedia:(id<SJMediaModelProtocol>)media;
@end
NS_ASSUME_NONNULL_END
