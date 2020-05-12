//
//  SJSubtitleItem.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/8.
//

#import <Foundation/Foundation.h>
#import "SJSubtitlesPromptControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSubtitleItem : NSObject<SJSubtitleItem>
- (instancetype)initWithContent:(NSAttributedString *)content range:(SJTimeRange)range;
- (instancetype)initWithContent:(NSAttributedString *)content start:(NSTimeInterval)start end:(NSTimeInterval)end;

@property (nonatomic, copy, readonly) NSAttributedString *content;
@property (nonatomic, readonly) SJTimeRange range;
@end
NS_ASSUME_NONNULL_END
