//
//  SJVideoPlayerHelper.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//
//
//  集成播放器的时候, 可以直接将这个类拖入到你的项目中.
//
//  关于 vc 的一些方法, 我都封装到 block 里面了, 所以直接调用 helper 的对应方法即可.
//  例如 viewDidAppear 的时候, 请调用一下 helper.vc_viewDidAppearExeBlock() 即可.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"
#import <SJPrompt/SJPrompt.h>
#import "SJVideoPlayerURLAsset+SJControlAdd.h"

@class SJVideoPlayerURLAsset, SJLightweightTopItem, SJVideoPlayerFilmEditingConfig;

@protocol SJVideoPlayerHelperUseProtocol;

typedef NS_ENUM(NSUInteger, SJVideoPlayerType) {
    SJVideoPlayerType_Default,
    SJVideoPlayerType_Lightweight,
};


NS_ASSUME_NONNULL_BEGIN
//
//- (void)clickedPlayBtnOnTheTableCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView {
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    SJVideoPlayerURLAsset *asset =
//    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]
//                                         scrollView:self.tableView
//                                          indexPath:indexPath
//                                       superviewTag:playerParentView.tag];
//    asset.title = @"Video Title";
//    asset.alwaysShowTitle = YES;
//
//    [self.videoPlayerHelper playWithAsset:asset playerParentView:playerParentView];
//}
//
@interface SJVideoPlayerHelper : NSObject
@property (nonatomic, weak, readwrite) UIViewController<SJVideoPlayerHelperUseProtocol> *viewController;

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController;
- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController
                            playerType:(SJVideoPlayerType)playerType;
@end





@interface SJVideoPlayerHelper (FilmEditing)
#pragma mark readonly
@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingConfig *filmEditingConfig;

#pragma mark readwrite
@property (nonatomic) BOOL enableFilmEditing; // 是否开启视频剪辑(GIF/截取/截屏)
@end





@interface SJVideoPlayerHelper (SJVideoPlayerOperation) // 暴露出来的播放器的一些操作
#pragma mark readwrite
@property (nonatomic) BOOL disableRotation;
@property (nonatomic) BOOL lockScreen;
@property (nonatomic) CGFloat rate; // if changed, 'SJVideoPlayerHelperUseProtocol -> videoPlayerRateChanged:' will be called.

// play an asset
- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(UIView *)playerParentView;
- (void)clearPlayer;
- (void)clearAsset;
- (void)pause;
- (void)play;
@end





@interface SJVideoPlayerHelper (SJVideoPlayerProperty)  // 暴露出来的播放器的一些属性
#pragma mark readwrite
/// The block invoked when control layer appear state changed
@property (nonatomic, copy, nullable) void(^controlLayerAppearStateChangedExeBlock)(SJVideoPlayerHelper *helper, BOOL displayed); // 请配置控制层显示或消失执行的block

/// The block invoked when player rate changed
@property (nonatomic, copy, nullable) void(^playerRateChangedExeBlock)(SJVideoPlayerHelper *helper, float rate);

/// The block invoked when user clicked top item if video player type is `SJVideoPlayerType_Lightweight`
@property (nonatomic, copy, nullable) void(^userClickedTopItemOfLightweightControlLayerExeBlock)(SJVideoPlayerHelper *helper, SJLightweightTopItem *item);
/// Top layer showed items when video player type is `SJVideoPlayerType_Lightweight`
@property (nonatomic, strong, nullable) NSArray<SJLightweightTopItem *> *topItemsOfLightweightControlLayer;

#pragma mark readonly
@property (nonatomic, strong, readonly, nullable) SJVideoPlayerURLAsset *asset;
@property (nonatomic, strong, readonly, nullable) SJPrompt *prompt;
@property (nonatomic, strong, readonly) NSURL *currentPlayURL;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;
@end





@interface SJVideoPlayerHelper (UIViewControllerHelper)   // 关于视图控制器的一些操作
#pragma mark readonly
/// You should call it when view did appear
@property (nonatomic, copy, readonly) void(^vc_viewDidAppearExeBlock)(void);
/// You should call it when view will disappear
@property (nonatomic, copy, readonly) void(^vc_viewWillDisappearExeBlock)(void);
@property (nonatomic, copy, readonly) BOOL(^vc_prefersStatusBarHiddenExeBlock)(void);
@property (nonatomic, copy, readonly) UIStatusBarStyle(^vc_preferredStatusBarStyleExeBlock)(void);
@end


//// Copy

//// The code is fixed, you can copy it directly to the view controller
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    self.videoPlayerHelper.vc_viewDidAppearExeBlock();
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    self.videoPlayerHelper.vc_viewWillDisappearExeBlock();
//}
//
//- (BOOL)prefersStatusBarHidden {
//    return self.videoPlayerHelper.vc_prefersStatusBarHiddenExeBlock();
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return self.videoPlayerHelper.vc_preferredStatusBarStyleExeBlock();
//}
//
@protocol SJVideoPlayerHelperUseProtocol <NSObject>
@required
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;

- (BOOL)prefersStatusBarHidden;
- (UIStatusBarStyle)preferredStatusBarStyle;
@end

NS_ASSUME_NONNULL_END
