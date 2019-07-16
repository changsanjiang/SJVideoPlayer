//
//  SJPlayerView.h
//  Pods
//
//  Created by BlueDancer on 2019/3/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayerView : UIView
@property (nonatomic, copy, nullable) void(^willMoveToWindowExeBlock)(SJPlayerView *view, UIWindow * window);
@property (nonatomic, copy, nullable) void(^layoutSubviewsExeBlock)(SJPlayerView *view);
@property (nonatomic, weak, nullable) id player;
@end
NS_ASSUME_NONNULL_END
