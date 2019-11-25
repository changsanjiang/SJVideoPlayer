//
//  UIView+SJBaseVideoPlayerExtended.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJBaseVideoPlayerExtended)

- (BOOL)isViewAppeared:(UIView *_Nullable)childView;

- (CGRect)intersectionWithView:(UIView *)view;

- (__kindof UIResponder *_Nullable)lookupResponderForClass:(Class)cls;
@end
NS_ASSUME_NONNULL_END
