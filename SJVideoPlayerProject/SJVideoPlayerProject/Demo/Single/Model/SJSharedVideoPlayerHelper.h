//
//  SJSharedVideoPlayerHelper.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/23.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SJSharedVideoPlayerHelperUseProtocol;


@interface SJSharedVideoPlayerHelper : NSObject

+ (instancetype)sharedHelper;

@property (nonatomic, weak, readwrite, nullable) UIViewController<SJSharedVideoPlayerHelperUseProtocol> *viewController;

@property (nonatomic, copy, readonly) void(^vc_viewWillAppearExeBlock)(void);
@property (nonatomic, copy, readonly) void(^vc_viewWillDisappearExeBlock)(void);
@property (nonatomic, copy, readonly) void(^vc_viewDidDisappearExeBlock)(void);
@property (nonatomic, copy, readonly) void(^vc_DeallocExeBlock)(void);
@property (nonatomic, copy, readonly) BOOL(^vc_prefersStatusBarHiddenExeBlock)(void);
@property (nonatomic, copy, readonly) UIStatusBarStyle(^vc_preferredStatusBarStyleExeBlock)(void);

@end


@protocol SJSharedVideoPlayerHelperUseProtocol <NSObject>

@required

- (void)dealloc;

- (void)viewWillAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;

- (void)viewDidDisappear:(BOOL)animated;

- (BOOL)prefersStatusBarHidden;

- (UIStatusBarStyle)preferredStatusBarStyle;
@end

NS_ASSUME_NONNULL_END

