//
//  SJSubtitlesPromptController.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/8.
//

#import <Foundation/Foundation.h>
#import "SJSubtitlesPromptControllerDefines.h"
#import "SJSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSubtitlesPromptController : NSObject<SJSubtitlesPromptController>

///
/// 设置未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<SJSubtitleItem *> *subtitles;

///
/// 内容可显示几行
///
///     default value is 0
///
@property (nonatomic) NSInteger numberOfLines;

///
/// 设置内边距
///
///     default value is zero
///
@property (nonatomic) UIEdgeInsets contentInsets;

@end
NS_ASSUME_NONNULL_END
