//
//  SJRotationFullscreenWindow.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJRotationManager.h"
@protocol SJRotationFullscreenWindowDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationFullscreenWindow : UIWindow
- (instancetype)initWithFrame:(CGRect)frame delegate:(nullable id<SJRotationFullscreenWindowDelegate>)delegate;
- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene delegate:(nullable id<SJRotationFullscreenWindowDelegate>)delegate API_AVAILABLE(ios(13.0));

@property (nonatomic, weak, nullable) SJRotationManager *rotationManager;

@end

@protocol SJRotationFullscreenWindowDelegate <NSObject>
- (BOOL)window:(SJRotationFullscreenWindow *)window pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event;
@end
NS_ASSUME_NONNULL_END
