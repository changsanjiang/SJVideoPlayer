//
//  SJModalViewControlllerManagerProtocol.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2019/1/28.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#ifndef SJModalViewControlllerManagerProtocol_h
#define SJModalViewControlllerManagerProtocol_h
@class SJVideoPlayerURLAsset;

NS_ASSUME_NONNULL_BEGIN
@protocol SJModalViewControllerPlayer <NSObject>
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *URLAsset;
- (void)controlLayerNeedAppear;
- (void)controlLayerNeedDisappear;
- (BOOL)vc_prefersStatusBarHidden;
- (UIStatusBarStyle)vc_preferredStatusBarStyle;
@end

@protocol SJModalViewControlllerManagerProtocol <NSObject>
@property (nonatomic, readonly, getter=isPresentedModalViewControlller) BOOL presentedModalViewControlller;
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;
- (void)presentModalViewControlllerWithTarget:(__weak UIView *)target
                              targetSuperView:(__weak UIView *)targetSuperView
                                       player:(__weak id<SJModalViewControllerPlayer>)player
                                   completion:(void (^ __nullable)(void))completion;
- (void)dismissModalViewControlllerCompletion:(void (^ __nullable)(void))completion;
@end
NS_ASSUME_NONNULL_END
#endif /* SJModalViewControlllerManagerProtocol_h */
