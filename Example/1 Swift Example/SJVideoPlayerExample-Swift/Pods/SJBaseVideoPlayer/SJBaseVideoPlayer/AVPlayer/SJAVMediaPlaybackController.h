//
//  SJAVMediaPlaybackController.h
//  Pods
//
//  Created by 畅三江 on 2020/2/18.
//

#import "SJMediaPlaybackController.h"
#import "SJAVMediaPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlaybackController : SJMediaPlaybackController

@property (nonatomic, strong, readonly, nullable) SJAVMediaPlayer *currentPlayer;
@property (nonatomic) BOOL accurateSeeking;

@end

@interface SJAVMediaPlaybackController (SJAVMediaPlaybackAdd)<SJMediaPlaybackExportController, SJMediaPlaybackScreenshotController>

@end
NS_ASSUME_NONNULL_END
