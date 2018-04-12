//
//  SJVideoPlayerHelper.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"

/**
 集成播放器的时候, 可以直接将这个类拖入到你的项目中.
 
 你可以在 SJVideoPlayerHelper.m 里, 将不需要的功能删除掉即可.
 关于 vc 的一些方法, 我都封装到 block 里面了, 所以直接调用 helper 的对应方法即可.
 例如 viewDidAppear 的时候, 请调用一下 helper.vc_viewDidAppearExeBlock() 即可.
 */

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerURLAsset;

@protocol SJVideoPlayerHelperUseProtocol;

typedef NS_ENUM(NSUInteger, SJVideoPlayerType) {
    SJVideoPlayerType_Default,
    SJVideoPlayerType_Lightweight,
};




@interface SJVideoPlayerHelper : NSObject

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController playerType:(SJVideoPlayerType)playerType;

/// return instance
- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController;

@property (nonatomic, weak, readwrite) UIViewController<SJVideoPlayerHelperUseProtocol> *viewController;
@property (nonatomic, weak, nullable) id<SJVideoPlayerFilmEditingResultUpload> uploader; //  请设置, 上传 截屏/导出视频/GIF 时使用.

/// play an asset.
- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(UIView *)playerParentView;

- (void)clearAsset;




@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;
@property (nonatomic, strong, readonly) NSURL *currentPlayURL;
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
- (BOOL)needConvertExternalAsset; // 是否需要转换外部传入的资源.

@end

NS_ASSUME_NONNULL_END
