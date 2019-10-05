//
//  SJPlayerView.m
//  Pods
//
//  Created by 畅三江 on 2019/3/28.
//

#import "SJPlayerView.h"
#import "SJBaseVideoPlayerConst.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlayerView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tag = SJBaseVideoPlayerViewTag;
    }
    return self;
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *_Nullable view = [super hitTest:point withEvent:event];
    
    if ( [self.delegate respondsToSelector:@selector(playerView:hitTestForView:)] ) {
        return [self.delegate playerView:self hitTestForView:view];
    }
    
    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( [self.delegate respondsToSelector:@selector(playerViewDidLayoutSubviews:)] ) {
        [self.delegate playerViewDidLayoutSubviews:self];
    }
}

- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self.window != nil ) {
            if ( [self.delegate respondsToSelector:@selector(playerViewWillMoveToWindow:)] ) {
                [self.delegate playerViewWillMoveToWindow:self];
            }
        }
    });
}
@end
NS_ASSUME_NONNULL_END
