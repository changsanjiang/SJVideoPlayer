//
//  SJListViewAutoplayViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/8/16.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJListViewAutoplayViewController.h"
#import <Masonry/Masonry.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>
#import <SJBaseVideoPlayer/SJVideoPlayerURLAssetPrefetcher.h>
#import <SJUIKit/UIScrollView+SJRefreshAdd.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SJListViewAutoplayMediaViewModel.h"

#define PlayerSuperviewTag 101

NS_ASSUME_NONNULL_BEGIN
@interface SJListViewAutoplayViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, SJPlayerAutoplayDelegate>
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableArray<SJListViewAutoplayMediaViewModel *> *viewModels;
@property (nonatomic, strong, readonly) SJVideoPlayerURLAssetPrefetcher *prefetcher;
@property (nonatomic, strong, nullable) SJBaseVideoPlayer *player;
@end

@implementation SJListViewAutoplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self.collectionView sj_exeHeaderRefreshing];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.player.timeControlStatus == SJPlaybackTimeControlStatusPaused ? [self.player play] : [self.player pause];
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    
    if ( indexPath != nil ) {
        if ( !_player ) {
            _player = [SJBaseVideoPlayer player];
            _player.delayInSecondsForHiddenPlaceholderImageView = 0.3;
            _player.rotationManager.disabledAutorotation = YES;
            _player.gestureControl.supportedGestureTypes = SJPlayerGestureTypeMask_None;
            _player.controlLayerAppearManager.disabled = YES;
            _player.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _player.view.backgroundColor = UIColor.clearColor;
            _player.view.subviews.firstObject.backgroundColor = UIColor.clearColor;
            __weak typeof(self) _self = self;
            _player.playbackObserver.timeControlStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self _refreshCellContent];
            };
            _player.playbackObserver.assetStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self _refreshCellContent];
            };
        }
        
        NSInteger curr = indexPath.item;
        NSInteger previous = curr - 1;
        NSInteger next = curr + 1;
        
        // 预加载前一个视频
        if ( previous >= 0 ) {
            [self.prefetcher prefetchAsset:[[SJVideoPlayerURLAsset alloc] initWithURL:_viewModels[previous].media.URL playModel:[SJPlayModel UICollectionViewCellPlayModelWithPlayerSuperviewTag:PlayerSuperviewTag atIndexPath:[NSIndexPath indexPathForItem:previous inSection:indexPath.section] collectionView:self.collectionView]]];
        }
        
        // 预加载下一个视频
        if ( next < _viewModels.count ) {
            [self.prefetcher prefetchAsset:[[SJVideoPlayerURLAsset alloc] initWithURL:_viewModels[next].media.URL playModel:[SJPlayModel UICollectionViewCellPlayModelWithPlayerSuperviewTag:PlayerSuperviewTag atIndexPath:[NSIndexPath indexPathForItem:next inSection:indexPath.section] collectionView:self.collectionView]]];
        }
        
        SJVideoPlayerURLAsset *_Nullable asset = [self.prefetcher assetForURL:_viewModels[curr].media.URL];
        
        if ( asset == nil ) {
            asset = [[SJVideoPlayerURLAsset alloc] initWithURL:_viewModels[curr].media.URL playModel:[SJPlayModel UICollectionViewCellPlayModelWithPlayerSuperviewTag:PlayerSuperviewTag atIndexPath:indexPath collectionView:self.collectionView]];
            [self.prefetcher prefetchAsset:asset];
        }
        
        [self.player.presentView.placeholderImageView sd_setImageWithURL:[NSURL URLWithString:_viewModels[curr].cover]];
        self.viewModels[self.collectionView.sj_currentPlayingIndexPath.item].showPausedImageView = NO;
        self.player.URLAsset = asset;
        [self.player play];
    }
}

- (void)_refreshCellContent {
    if ( self.collectionView.sj_currentPlayingIndexPath.item < self.viewModels.count ) {
        SJListViewAutoplayMediaViewModel *vm = self.viewModels[self.collectionView.sj_currentPlayingIndexPath.item];
        switch ( self.player.assetStatus ) {
            case SJAssetStatusUnknown:
            case SJAssetStatusPreparing:
                vm.showPausedImageView = NO;
                break;
            case SJAssetStatusReadyToPlay: {
                vm.showPausedImageView = self.player.timeControlStatus == SJPlaybackTimeControlStatusPaused;
            }
                break;
            case SJAssetStatusFailed:
                // .. failed
                break;
        }
        [(SJListViewAutoplayCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.collectionView.sj_currentPlayingIndexPath] refreshData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player vc_viewWillDisappear];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
#pragma mark -

- (void)_setupViews {
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithPlayerSuperviewTag:PlayerSuperviewTag autoplayDelegate:self];
    [_collectionView sj_enableAutoplayWithConfig:config];
    
    __weak typeof(self) _self = self;
    [_collectionView sj_setupRefreshingWithPageSize:20 beginPageNum:0 refreshingBlock:^(__kindof UIScrollView * _Nonnull collectionView, NSInteger requestPageNum) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        __auto_type medias = [SJMeidaItemModel testItemsWithCount:collectionView.sj_pageSize];
        NSMutableArray<SJListViewAutoplayMediaViewModel *> *viewModels = [NSMutableArray arrayWithCapacity:medias.count];
        for ( SJMeidaItemModel *media in medias ) {
            [viewModels addObject:[[SJListViewAutoplayMediaViewModel alloc] initWithItem:media tag:PlayerSuperviewTag]];
        }
        
        if ( requestPageNum == collectionView.sj_beginPageNum ) {
            [self.viewModels removeAllObjects];
            [self.player.view removeFromSuperview];
            self.player.URLAsset = nil;
            self.collectionView.sj_currentPlayingIndexPath = nil;
            [self.collectionView sj_playNextVisibleAsset];
        }
        
        [self.viewModels addObjectsFromArray:viewModels];
        [self.collectionView sj_endRefreshingWithItemCount:medias.count];
        [self.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJListViewAutoplayCollectionViewCell cellWithCollectionView:_collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJListViewAutoplayCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = self.viewModels[indexPath.item];
    [cell refreshData];
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if ( _collectionView == nil ) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = UIScreen.mainScreen.bounds.size;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.blackColor;
        _collectionView.pagingEnabled = YES;
        [SJListViewAutoplayCollectionViewCell registerWithCollectionView:_collectionView];
    }
    return _collectionView;
}

@synthesize viewModels = _viewModels;
- (NSMutableArray<SJListViewAutoplayMediaViewModel *> *)viewModels {
    if ( _viewModels == nil ) {
        _viewModels = [NSMutableArray new];
    }
    return _viewModels;
}

@synthesize prefetcher = _prefetcher;
- (SJVideoPlayerURLAssetPrefetcher *)prefetcher {
    if ( _prefetcher == nil ) {
        _prefetcher = [SJVideoPlayerURLAssetPrefetcher new];
    }
    return _prefetcher;
}
@end
NS_ASSUME_NONNULL_END





#import <SJRouter/SJRouter.h>
@interface SJListViewAutoplayViewController (RouteHandler)<SJRouteHandler>

@end

@implementation SJListViewAutoplayViewController (RouteHandler)

+ (NSString *)routePath {
    return @"demo/collectionView/autoplay3";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}
@end
