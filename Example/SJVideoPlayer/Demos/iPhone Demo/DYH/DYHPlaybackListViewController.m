//
//  DYHPlaybackListViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "DYHPlaybackListViewController.h"
#import "DYHCollectionViewCell.h"
#import "SJSourceURLs.h"
#import "SJDYDataProvider.h"

#import <SJUIKit/UIScrollView+SJRefreshAdd.h>
#import <Masonry/Masonry.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJAVMediaPlayer.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>
#import <SJMediaCacheServer/SJMediaCacheServer.h>
#import <SJBaseVideoPlayer/UIView+SJBaseVideoPlayerExtended.h>

@interface DYHPlaybackListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SJDYDataProvider *dataProvider;
@property (nonatomic, strong) NSMutableArray<SJVideoModel *> *list;
@property (nonatomic, strong) id<DYHDemoPlayer> curPlayer;

@property (nonatomic, strong, nullable) id<MCSPrefetchTask> prePrefetchTask;
@property (nonatomic, strong, nullable) id<MCSPrefetchTask> nextPrefetchTask;
@end

@implementation DYHPlaybackListViewController
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _setupMediaCacheServer];
    [self _setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    [_prePrefetchTask cancel];
    [_nextPrefetchTask cancel];
}

// 当用户暂停时, 将不会调用播放
- (void)playIfNeeded {
    if ( !_curPlayer.isUserPaused ) [_curPlayer play];
}

// 暂停播放. 如果该方法调用之前用户已暂停播放了, 当执行此操作时不会影响用户暂停态
- (void)pause {
    if ( !_curPlayer.isPaused ) [_curPlayer pause];
}

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [DYHCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(DYHCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *playbackURL = [SJMediaCacheServer.shared playbackURLWithURL:_list[indexPath.row].URL];
    [cell.player configureWithURL:playbackURL];
    if ( _curPlayer == nil ) {
        _curPlayer = cell.player;
        [_curPlayer play];
    }
    [_prePrefetchTask cancel];
    [_nextPrefetchTask cancel];
    _prePrefetchTask = [self _prefetchTaskWithIndex:indexPath.row - 1];
    _nextPrefetchTask = [self _prefetchTaskWithIndex:indexPath.row + 1];
}
 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _checkVisibleCells];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( !decelerate ) [self _checkVisibleCells];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self _checkVisibleCells];
}

#pragma mark - mark

- (void)_checkVisibleCells {
    DYHCollectionViewCell *target = nil;
    CGRect max = CGRectZero;
    for ( DYHCollectionViewCell *cell in _collectionView.visibleCells ) {
        CGRect intersection = [cell intersectionWithView:_collectionView insets:UIEdgeInsetsZero];
        if ( intersection.size.height > max.size.height ) {
            target = cell;
            max = intersection;
        }
    }

    if ( target == nil )
        return;
    
    id<DYHDemoPlayer> cur = target.player;
    if ( cur != _curPlayer ) {
        [_curPlayer pause];
    }

    _curPlayer = cur;

    if ( !_curPlayer.isUserPaused ) {
        [_curPlayer play];
    }
}

#pragma mark -
 
- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.blackColor;
    self.view.clipsToBounds = YES;
    _list = NSMutableArray.alloc.init;
    _dataProvider = SJDYDataProvider.alloc.init;
}
 
- (void)_setupTableView {
    UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.alloc.init;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.estimatedItemSize = CGSizeZero;

    _collectionView = [UICollectionView.alloc initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.blackColor;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [DYHCollectionViewCell registerWithCollectionView:_collectionView];

    // 请求列表数据
    //      模拟请求网络数据
    __weak typeof(self) _self = self;
    // 模拟延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dataProvider playbackListWithPageNum:0 pageSize:20 completionHandler:^(NSArray<SJVideoModel *> * _Nullable list, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( error ) {
                // error
                NSLog(@"%@", error);
                return;
            }

            // 添加到播放列表中, 刷新列表
            [self.list addObjectsFromArray:list];
            [self.collectionView reloadData];
            [self _checkVisibleCells];
        }];
    });
}

// 配置边播边缓存模块
- (void)_setupMediaCacheServer {
    // 开启控制台log
    SJMediaCacheServer.shared.enabledConsoleLog = YES;
    SJMediaCacheServer.shared.resolveAssetIdentifier = ^NSString * _Nonnull(NSURL * _Nonnull URL) {
        // 由于demo中同一个视频的URL后面的参数不一样, 为保证引用相同的缓存文件, 这里删除了URL后面的所有参数
        // 例如:
        //      - https://dh2.v.netease.com/2017/cg/fxtpty.mp4?id=0&key=value
        //      - https://dh2.v.netease.com/2017/cg/fxtpty.mp4?id=1
        //      这两个URL后面的参数不同, 但它们代表了同一个视频, 为保证引用相同的缓存文件, 这里需删除后面的所有参数, 保证返回的字符串一致
        return [URL.absoluteString stringByDeletingPathExtension];
    };
}

#pragma mark -

// 预加载指定位置的某个资源`1M`的内容
- (nullable id<MCSPrefetchTask>)_prefetchTaskWithIndex:(NSInteger)index {
    if ( index < 0 || index >= _list.count )
        return nil;
    return [SJMediaCacheServer.shared prefetchWithURL:_list[index].URL preloadSize:1 * 1024 * 1024];
}
@end
