//
//  SJSubtitlesPromptControllerDefines.h
//  Pods
//
//  Created by BlueDancer on 2019/11/8.
//

#ifndef SJSubtitlesPromptControllerDefines_h
#define SJSubtitlesPromptControllerDefines_h
#include <Foundation/Foundation.h>
@protocol SJSubtitleItem;
@class UIColor;

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    NSTimeInterval start;
    NSTimeInterval duration;
} SJTimeRange;

static inline SJTimeRange
SJMakeTimeRange(NSTimeInterval start, NSTimeInterval duration) {
    return (SJTimeRange){start, duration};
}

static inline BOOL
SJTimeRangeContainsTime(NSTimeInterval time, SJTimeRange range) {
    return (!(time < range.start) && (time - range.start) < range.duration) ? YES : NO;
}

@protocol SJSubtitlesPromptController <NSObject>

///
/// 设置未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<id<SJSubtitleItem>> *subtitles;

///
/// 内容可显示几行
///
///     default value is 0
///
@property (nonatomic) NSInteger numberOfLines;

/// 设置内边距
///
///     default value is zero
///
@property (nonatomic) UIEdgeInsets contentInsets;

///
/// 以下属性由播放器维护, 开发者无需设置
///
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic, strong, readonly) UIView *view;
@end


@protocol SJSubtitleItem <NSObject>
- (instancetype)initWithContent:(NSAttributedString *)content range:(SJTimeRange)range;
- (instancetype)initWithContent:(NSAttributedString *)content start:(NSTimeInterval)start end:(NSTimeInterval)end;
@property (nonatomic, copy, readonly) NSAttributedString *content;
@property (nonatomic, readonly) SJTimeRange range;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END

#endif /* SJSubtitlesPromptControllerDefines_h */
