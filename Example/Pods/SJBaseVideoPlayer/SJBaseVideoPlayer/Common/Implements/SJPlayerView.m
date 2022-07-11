//
//  SJPlayerView.m
//  Pods
//
//  Created by 畅三江 on 2019/3/28.
//

#import "SJPlayerView.h"
#import "SJPlayerViewInternal.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayerView ()
@property (nonatomic, strong, nullable) UIView *presentView;
@end

@implementation SJPlayerView

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *_Nullable view = [super hitTest:point withEvent:event];
    
    if ( [self.delegate respondsToSelector:@selector(playerView:hitTestForView:)] ) {
        return [self.delegate playerView:self hitTestForView:view];
    }
    
    return view;
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
