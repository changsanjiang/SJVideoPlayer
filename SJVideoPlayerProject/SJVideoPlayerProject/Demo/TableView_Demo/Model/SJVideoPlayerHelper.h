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

/// return instance
- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController;

@property (nonatomic, weak, readwrite) UIViewController<SJVideoPlayerHelperUseProtocol> *viewController;

/// play an asset.
- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(UIView *)playerParentView;

- (void)clearAsset;

@property (nonatomic, strong, readonly, nullable) SJVideoPlayerURLAsset *asset;

@property (nonatomic, copy, readonly) void(^vc_viewDidAppearExeBlock)(void);

@property (nonatomic, copy, readonly) void(^vc_viewWillDisappearExeBlock)(void);

@property (nonatomic, copy, readonly) void(^vc_viewDidDisappearExeBlock)(void);

@property (nonatomic, copy, readonly) BOOL(^vc_prefersStatusBarHiddenExeBlock)(void);

@property (nonatomic, copy, readonly) UIStatusBarStyle(^vc_preferredStatusBarStyleExeBlock)(void);

@end

@protocol SJVideoPlayerHelperUseProtocol <NSObject>

@required

- (void)viewWillDisappear:(BOOL)animated;

- (void)viewDidAppear:(BOOL)animated;

- (void)viewDidDisappear:(BOOL)animated;

- (BOOL)prefersStatusBarHidden;

- (UIStatusBarStyle)preferredStatusBarStyle;

@optional
- (BOOL)needConvertAsset;

@end

NS_ASSUME_NONNULL_END
