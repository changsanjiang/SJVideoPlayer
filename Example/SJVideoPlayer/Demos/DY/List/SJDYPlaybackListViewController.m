//
//  SJDYPlaybackListViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJDYPlaybackListViewController.h"
#import "SJDYTableViewCell.h"
#import "SJSourceURLs.h"
#import "SJDYDataProvider.h"

#import <SJUIKit/UIScrollView+SJRefreshAdd.h>
#import <Masonry/Masonry.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>
#import <SJMediaCacheServer/SJMediaCacheServer.h>

@interface SJDYPlaybackListViewController ()<UITableViewDataSource, UITableViewDelegate, SJPlayerAutoplayDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SJBaseVideoPlayer *player;
@property (nonatomic, strong) SJDYDataProvider *dataProvider;
@property (nonatomic, strong) NSMutableArray<SJVideoModel *> *list;

@property (nonatomic, strong, nullable) id<MCSPrefetchTask> prePrefetchTask;
@property (nonatomic, strong, nullable) id<MCSPrefetchTask> nextPrefetchTask;
@end

@implementation SJDYPlaybackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _setupMediaCacheServer];
    [self _setupVideoPlayer];
    [self _setupTableView];
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath == nil )
        return;
    // 进行播放
    NSURL *URL = _list[indexPath.row].URL;
    NSURL *playbackURL = [SJMediaCacheServer.shared playbackURLWithURL:URL];
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:playbackURL playModel:[SJPlayModel playModelWithTableView:_tableView indexPath:indexPath]];
    [_player play];
    
    // 进行预加载
    [_prePrefetchTask cancel];
    [_nextPrefetchTask cancel];
    _prePrefetchTask = [self _prefetchTaskWithIndex:indexPath.row - 1]; // 预加载前一个视频
    _nextPrefetchTask = [self _prefetchTaskWithIndex:indexPath.row + 1]; // 预加载后一个视频
}

// 当用户暂停时, 将不会调用播放
- (void)playIfNeeded {
    if ( !_player.isUserPaused ) [_player play];
}

// 暂停播放. 如果该方法调用之前用户已暂停播放了, 当执行此操作时不会影响用户暂停态
- (void)pause {
    [_player pause];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJDYTableViewCell cellWithTableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJDYTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self _refreshCell:cell atIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size.height;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark -

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.blackColor;
    self.view.clipsToBounds = YES;
    _list = NSMutableArray.alloc.init;
    _dataProvider = SJDYDataProvider.alloc.init;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playIfNeeded) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(pause) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)_setupVideoPlayer {
    _player = SJBaseVideoPlayer.player;
    _player.view.backgroundColor = UIColor.clearColor;
    _player.presentView.backgroundColor = UIColor.clearColor;
    _player.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _player.autoplayWhenSetNewAsset = NO;
    _player.autoManageViewToFitOnScreenOrRotation = NO;
    _player.rotationManager.disabledAutorotation = YES;
    _player.pauseWhenAppDidEnterBackground = NO;
    _player.resumePlaybackWhenScrollAppeared = NO;
    _player.resumePlaybackWhenAppDidEnterForeground = NO;

    __weak typeof(self) _self = self;
    // 调用play时, 询问代理是否允许播放
    _player.canPlayAnAsset = ^BOOL(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        return [self.delegate canPerformPlayForListViewController:self];
    };
    
    // 播放完毕后, 重新播放. 也就是循环播放
    _player.playbackObserver.playbackDidFinishExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        [player replay];
    };
    
    // 设置仅支持单击手势
    _player.gestureControl.supportedGestureTypes = SJPlayerGestureTypeMask_SingleTap;
    // 重新定义单击手势的处理, 这里为 单击暂停或播放
    _player.gestureControl.singleTapHandler = ^(id<SJPlayerGestureControl>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.player.isPaused ? [self.player play] : [self.player pauseForUser];
    };
    
    // 播放状态改变后刷新cell显示
    _player.playbackObserver.timeControlStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSIndexPath *indexPath = self.tableView.sj_currentPlayingIndexPath;
        if ( indexPath == nil )
            return;
        [self _refreshCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    };
}

- (void)_setupTableView {
    _tableView = [UITableView.alloc initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = UIColor.blackColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.pagingEnabled = YES;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [SJDYTableViewCell registerWithTableView:_tableView];
    
    // 请求列表数据
    //      模拟请求网络数据
    __weak typeof(self) _self = self;
    [_tableView sj_setupRefreshingWithPageSize:20 beginPageNum:1 refreshingBlock:^(__kindof UIScrollView * _Nonnull scrollView, NSInteger requestPageNum) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.dataProvider playbackListWithPageNum:self.tableView.sj_pageNum pageSize:self.tableView.sj_pageSize completionHandler:^(NSArray<SJVideoModel *> * _Nullable list, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( error ) {
                // error
                NSLog(@"%@", error);
                return;
            }
            if ( self.tableView.sj_pageNum == self.tableView.sj_beginPageNum ) {
                // 下拉刷新时, 清理所有的数据
                [self.list removeAllObjects];
                [self.tableView sj_removeCurrentPlayerView];
                self.player.URLAsset = nil;
            }
            // 添加到播放列表中, 刷新列表
            [self.list addObjectsFromArray:list];
            [self.tableView reloadData];
            [self.tableView sj_endRefreshingWithItemCount:list.count];
            [self.tableView sj_playNextVisibleAsset];
        }];
    }];
    
    [_tableView sj_exeHeaderRefreshingAnimated:NO]; // 执行头部刷新
    
    // 配置自动播放
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithAutoplayDelegate:self];
    [_tableView sj_enableAutoplayWithConfig:config];
}

// 配置边播边缓存模块
- (void)_setupMediaCacheServer {
    // 开启控制台log
    SJMediaCacheServer.shared.enabledConsoleLog = YES;
    SJMediaCacheServer.shared.resolveResourceIdentifier = ^NSString * _Nonnull(NSURL * _Nonnull URL) {
        // 由于demo中同一个视频的URL后面的参数不一样, 为保证引用相同的缓存文件, 这里删除了URL后面的所有参数
        // 例如:
        //      - https://dh2.v.netease.com/2017/cg/fxtpty.mp4?id=0&key=value
        //      - https://dh2.v.netease.com/2017/cg/fxtpty.mp4?id=1
        //      这两个URL后面的参数不同, 但它们代表了同一个视频, 为保证引用相同的缓存文件, 这里需删除后面的所有参数, 保证返回的字符串一致
        return [URL.absoluteString stringByDeletingPathExtension];
    };
}

#pragma mark -

- (void)_refreshCell:(SJDYTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *current = _player.URLAsset.playModel.indexPath;
    // 当前播放的indexPath是否一致
    if ( [current isEqual:indexPath] ) {
        // 如果播放器处于暂停状态, 并且是用户暂停的, 则显示暂停按钮
        if ( _player.isPaused ) {
            cell.isPlayImageViewHidden = !_player.isUserPaused;
        }
        else
            cell.isPlayImageViewHidden = YES;
    }
    else {
        cell.isPlayImageViewHidden = YES;
    }
}

// 预加载指定位置的某个资源`10M`的内容
- (nullable id<MCSPrefetchTask>)_prefetchTaskWithIndex:(NSInteger)index {
    if ( index < 0 || index >= _list.count )
        return nil;
    return [SJMediaCacheServer.shared prefetchWithURL:_list[index].URL preloadSize:10 * 1024 * 1024];
}
@end
