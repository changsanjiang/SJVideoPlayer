//
//  ViewControllerCollectionViewAutoPlay.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerCollectionViewAutoPlay.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import "SJVideoPlayer.h"
#import "SJCollectionViewCell.h"
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>

@interface ViewControllerCollectionViewAutoPlay ()<SJRouteHandler, UICollectionViewDelegate, UICollectionViewDataSource, SJPlayerAutoplayDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) UIView *midLine;
@end

@implementation ViewControllerCollectionViewAutoPlay

+ (NSString *)routePath {
    return @"collectionView/autoplay";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _setupViews];
    [self _configAutoplayForCollectionView];
    // Do any additional setup after loading the view.
}

// 配置列表自动播放
- (void)_configAutoplayForCollectionView {
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithPlayerSuperviewTag:101 autoplayDelegate:self];
    config.autoplayPosition = SJAutoplayPositionMiddle;
    [_collectionView sj_enableAutoplayWithConfig:config];
    [_collectionView sj_playNextVisibleAsset];
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    SJCollectionViewCell *cell = (SJCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if ( !_player || !_player.isFullScreen ) {
        [_player stopAndFadeOut]; // 让旧的播放器淡出
        _player = [SJVideoPlayer player]; // 创建一个新的播放器
        // fade in(淡入)
        _player.view.alpha = 0.001;
        [UIView animateWithDuration:0.6 animations:^{
            self.player.view.alpha = 1;
        }];
        
        _player.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        __weak typeof(self) _self = self;
        _player.playDidToEndExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            NSIndexPath *next = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
            [self.collectionView scrollToItemAtIndexPath:next atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        };
    }
#ifdef SJMAC
    _player.disablePromptWhenNetworkStatusChanges = YES;
#endif
    
    _player.resumePlaybackWhenPlayerViewScrollAppears = YES;
    [cell.view.coverImageView addSubview:self.player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"https://xy2.v.netease.com/2018/0815/d08adab31cc9e6ce36111afc8a92c937qt.mp4"] playModel:[SJPlayModel UICollectionViewCellPlayModelWithPlayerSuperviewTag:cell.view.coverImageView.tag atIndexPath:indexPath collectionView:_collectionView]];
    self.player.URLAsset.title = @"十五年前, 一见钟情"; 
}

- (void)_setupViews {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [SJCollectionViewCell registerWithCollectionView:_collectionView];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    _midLine = [[UIView alloc] initWithFrame:CGRectZero];
    _midLine.backgroundColor = [UIColor redColor];
    [self.view addSubview:_midLine];
    [_midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.centerY.offset(0);
        make.height.offset(2);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) _self = self;
    cell.view.clickedPlayButtonExeBlock = ^(SJPlayView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
//    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end
