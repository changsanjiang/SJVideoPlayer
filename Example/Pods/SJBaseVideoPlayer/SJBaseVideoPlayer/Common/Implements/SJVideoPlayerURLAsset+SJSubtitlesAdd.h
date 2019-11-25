//
//  SJVideoPlayerURLAsset+SJSubtitlesAdd.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/8.
//

#import "SJVideoPlayerURLAsset.h"
#import "SJSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerURLAsset (SJSubtitlesAdd)
///
/// 未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<SJSubtitleItem *> *subtitles;

@end

NS_ASSUME_NONNULL_END
