//
//  UIView+SJBaseVideoPlayerExtended.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJBaseVideoPlayerExtended)

- (BOOL)isViewAppeared:(UIView *_Nullable)childView;

- (CGRect)intersectionWithView:(UIView *)view;

- (__kindof UIResponder *_Nullable)lookupResponderForClass:(Class)cls;

@property (nonatomic) CGFloat sj_x;
@property (nonatomic) CGFloat sj_y;
@property (nonatomic) CGFloat sj_w;
@property (nonatomic) CGFloat sj_h;
@property (nonatomic) CGSize sj_size;
@end
NS_ASSUME_NONNULL_END
