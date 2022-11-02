//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/11/29.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerPresentViewDefines.h"
#import "SJGestureControllerDefines.h"
@protocol SJVideoPlayerPresentViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerPresentView : UIView<SJVideoPlayerPresentView, SJGestureController>
@property (nonatomic, weak, nullable) id<SJVideoPlayerPresentViewDelegate> delegate;
@end

@protocol SJVideoPlayerPresentViewDelegate <NSObject>
@optional
- (void)presentViewDidLayoutSubviews:(SJVideoPlayerPresentView *)presentView;
- (void)presentViewDidMoveToWindow:(SJVideoPlayerPresentView *)presentView;
@end
NS_ASSUME_NONNULL_END
