//
//  SJRotationManager.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/13.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJRotationManagerDefines.h"
@protocol SJRotationManagerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManager : NSObject<SJRotationManager>
@property (nonatomic, weak, nullable) id<SJRotationManagerDelegate> delegate;
@end

@protocol SJRotationManagerDelegate <NSObject>
- (BOOL)prefersStatusBarHidden;
- (UIStatusBarStyle)preferredStatusBarStyle;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end
NS_ASSUME_NONNULL_END
