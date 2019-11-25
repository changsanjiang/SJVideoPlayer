//
//  SJSubtitleItem.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/8.
//

#import "SJSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJSubtitleItem
- (instancetype)initWithContent:(NSAttributedString *)content range:(SJTimeRange)range {
    self = [super init];
    if ( self ) {
        _content = content.copy;
        _range = range;
    }
    return self;
}

- (instancetype)initWithContent:(NSAttributedString *)content start:(NSTimeInterval)start end:(NSTimeInterval)end {
    return [self initWithContent:content range:SJMakeTimeRange(start, end - start)];
}
@end
NS_ASSUME_NONNULL_END
