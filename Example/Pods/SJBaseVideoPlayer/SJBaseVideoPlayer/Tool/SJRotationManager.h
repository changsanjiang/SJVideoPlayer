//
//  SJRotationManager.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/13.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJRotationManagerDefines.h>
#else
#import "SJRotationManagerDefines.h"
#endif
@protocol SJRotationManagerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManager : NSObject<SJRotationManagerProtocol>
@property (nonatomic, weak, nullable) id<SJRotationManagerDelegate> delegate;
@end

@protocol SJRotationManagerDelegate <NSObject>
- (BOOL)vc_prefersStatusBarHidden;
- (UIStatusBarStyle)vc_preferredStatusBarStyle;
- (void)vc_forwardPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end
NS_ASSUME_NONNULL_END
