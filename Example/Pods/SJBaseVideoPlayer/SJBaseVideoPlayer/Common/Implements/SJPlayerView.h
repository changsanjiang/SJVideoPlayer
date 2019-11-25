//
//  SJPlayerView.h
//  Pods
//
//  Created by 畅三江 on 2019/3/28.
//

#import <UIKit/UIKit.h>

@protocol SJPlayerViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayerView : UIView
@property (nonatomic, weak, nullable) id<SJPlayerViewDelegate> delegate;
@end

@protocol SJPlayerViewDelegate <NSObject>
- (void)playerViewDidLayoutSubviews:(SJPlayerView *)playerView;
- (void)playerViewWillMoveToWindow:(SJPlayerView *)playerView;
- (nullable UIView *)playerView:(SJPlayerView *)playerView hitTestForView:(nullable __kindof UIView *)view;
@end
NS_ASSUME_NONNULL_END
