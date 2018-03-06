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

@property (nonatomic, strong, readonly, nullable) SJVideoPlayerURLAsset *asset;

@property (nonatomic, copy, readonly) void(^vc_viewWillAppearExeBlock)(void);

@property (nonatomic, copy, readonly) void(^vc_viewDidAppearExeBlock)(void);

@property (nonatomic, copy, readonly) void(^vc_viewWillDisappearExeBlock)(void);

@property (nonatomic, copy, readonly) void(^vc_viewDidDisappearExeBlock)(void);

@property (nonatomic, copy, readonly) BOOL(^vc_prefersStatusBarHiddenExeBlock)(void);

@property (nonatomic, copy, readonly) UIStatusBarStyle(^vc_preferredStatusBarStyleExeBlock)(void);

@end

@protocol SJVideoPlayerHelperUseProtocol <NSObject>

@required

- (void)viewWillAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;

- (void)viewDidAppear:(BOOL)animated;

- (void)viewDidDisappear:(BOOL)animated;

- (BOOL)prefersStatusBarHidden;

- (UIStatusBarStyle)preferredStatusBarStyle;

@end

NS_ASSUME_NONNULL_END

/*
@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
 
@synthesize videoPlayerHelper = _videoPlayerHelper;
- (SJVideoPlayerHelper *)videoPlayerHelper {
    if ( _videoPlayerHelper ) return _videoPlayerHelper;
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self];
    return _videoPlayerHelper;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.videoPlayerHelper.vc_viewWillAppearExeBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.videoPlayerHelper.vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.videoPlayerHelper.vc_viewDidDisappearExeBlock();
}

- (BOOL)prefersStatusBarHidden {
    return self.videoPlayerHelper.vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.videoPlayerHelper.vc_preferredStatusBarStyleExeBlock();
}
*/
