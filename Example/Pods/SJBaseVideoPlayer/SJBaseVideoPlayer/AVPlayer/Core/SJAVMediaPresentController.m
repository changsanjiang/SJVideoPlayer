//
//  SJAVMediaPresentController.m
//  Pods
//
//  Created by 畅三江 on 2019/10/5.
//

#import "SJAVMediaPresentController.h"

NS_ASSUME_NONNULL_BEGIN
@interface _SJAVMediaPresentControllerView : UIView
@end
@implementation _SJAVMediaPresentControllerView
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    for ( UIView *subview in self.subviews ) {
        subview.frame = bounds;
    }
}
@end
 
@implementation SJAVMediaPresentController {
    _SJAVMediaPresentControllerView *_view;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _videoGravity = AVLayerVideoGravityResizeAspect;
    _view = _SJAVMediaPresentControllerView.alloc.init;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(presentViewReadyForDisplayDidChange:) name:SJAVMediaPresentViewReadyForDisplayDidChangeNotification object:nil];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)presentViewReadyForDisplayDidChange:(NSNotification *)note {
    if ( [self.view.subviews containsObject:note.object] ) {
        if ( [self.delegate respondsToSelector:@selector(presentController:presentViewReadyForDisplayDidChange:)] ) {
            [self.delegate presentController:self presentViewReadyForDisplayDidChange:note.object];
        }
    }
}

- (nullable SJAVMediaPresentView *)keyPresentView {
    return _view.subviews.lastObject;
}

- (void)setVideoGravity:(nullable AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity ? : AVLayerVideoGravityResizeAspect;
    self.keyPresentView.videoGravity = videoGravity;
}

- (void)insertPresentViewToBack:(SJAVMediaPresentView *)view {
    if ( view != nil ) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        view.videoGravity = _videoGravity;
        view.frame = self.view.bounds;
        [CATransaction commit];
        [self.view insertSubview:view atIndex:0];
    }
}

- (void)removePresentView:(SJAVMediaPresentView *)view {
    if ( view != nil ) {
        [view removeFromSuperview];
    }
}

- (void)makeKeyPresentView:(SJAVMediaPresentView *)view {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    view.videoGravity = _videoGravity;
    [CATransaction commit];
    if ( view != nil && self.keyPresentView != view ) {
        [self removePresentView:view];
        [self.view addSubview:view];
    }
}

- (void)removeAllPresentView {
    [self.view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SJAVMediaPresentView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removePresentView:obj];
    }];
}
@end
NS_ASSUME_NONNULL_END
