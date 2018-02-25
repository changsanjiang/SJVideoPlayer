//
//  SJSharedVideoPlayerHelper.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/23.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJVideoPlayerURLAsset;
@protocol SJSharedVideoPlayerHelperUseProtocol;


#pragma mark -

@interface SJSharedVideoPlayerHelper : NSObject

+ (instancetype)sharedHelper;

@property (nonatomic, copy, readonly) void(^vc_viewWillAppearExeBlock)(UIViewController<SJSharedVideoPlayerHelperUseProtocol> *vc, SJVideoPlayerURLAsset * __nullable asset);

@property (nonatomic, copy, readonly) void(^vc_viewWillDisappearExeBlock)(void);

@property (nonatomic, copy, readonly) BOOL(^vc_prefersStatusBarHiddenExeBlock)(void);

@property (nonatomic, copy, readonly) UIStatusBarStyle(^vc_preferredStatusBarStyleExeBlock)(void);

@property (nonatomic, copy, readonly) void(^vc_deallocExeBlock)(void);

@end


@protocol SJSharedVideoPlayerHelperUseProtocol <NSObject>

@required

- (UIView *)playerBackgroundView;   // 播放器的父视图

- (void)viewWillAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;

- (void)dealloc;

- (BOOL)prefersStatusBarHidden;

- (UIStatusBarStyle)preferredStatusBarStyle;
@end

NS_ASSUME_NONNULL_END

