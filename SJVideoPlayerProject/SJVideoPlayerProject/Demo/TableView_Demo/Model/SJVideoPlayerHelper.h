//
//  SJVideoPlayerHelper.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJVideoPlayerURLAsset;
@protocol SJVideoPlayerHelperUseProtocol;

@interface SJVideoPlayerHelper : NSObject

- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(UIView *)playerParentView;

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController;

@property (nonatomic, copy, readonly) void(^vc_viewWillAppearExeBlock)(void);

@property (nonatomic, copy, readonly) void(^vc_viewWillDisappearExeBlock)(void);

@property (nonatomic, copy, readonly) BOOL(^vc_prefersStatusBarHiddenExeBlock)(void);

@property (nonatomic, copy, readonly) UIStatusBarStyle(^vc_preferredStatusBarStyleExeBlock)(void);

@end

@protocol SJVideoPlayerHelperUseProtocol <NSObject>

@required

- (void)viewWillAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;

- (BOOL)prefersStatusBarHidden;

- (UIStatusBarStyle)preferredStatusBarStyle;
@end

NS_ASSUME_NONNULL_END
