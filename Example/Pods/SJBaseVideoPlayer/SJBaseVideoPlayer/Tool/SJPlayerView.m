//
//  SJPlayerView.m
//  Pods
//
//  Created by BlueDancer on 2019/3/28.
//

#import "SJPlayerView.h"
NS_ASSUME_NONNULL_BEGIN
@implementation SJPlayerView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutSubviewsExeBlock ) _layoutSubviewsExeBlock(self);
}

- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if ( !newWindow )
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self->_willMoveToWindowExeBlock ) self->_willMoveToWindowExeBlock(self, newWindow);
    });
}
@end
NS_ASSUME_NONNULL_END
