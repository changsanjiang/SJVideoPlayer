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
#import <SJBaseVideoPlayer/SJAVMediaPlayer.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>
#import <SJMediaCacheServer/SJMediaCacheServer.h>
#import <SJBaseVideoPlayer/UIView+SJBaseVideoPlayerExtended.h>

@interface SJDYPlaybackListViewController ()<UITableViewDataSource, UITableViewDelegate,MCSPrefetcherDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SJDYDataProvider *dataProvider;
@property (nonatomic, strong) NSMutableArray<SJVideoModel *> *list;
@property (nonatomic, strong) id<SJDYDemoPlayer> curPlayer;
@property (nonatomic, strong, nullable) id<MCSPrefetchTask> prePrefetchTask;
@property (nonatomic, strong, nullable) id<MCSPrefetchTask> nextPrefetchTask;
@property (nonatomic ,strong) NSMutableArray *prefetchTaskArray;
@property (nonatomic ,assign) BOOL isLoadingData;   //是否加载正在数据中
@property (nonatomic ,assign) BOOL isCacheData;     //是否有缓存数据
@end

@implementation SJDYPlaybackListViewController
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    [self _setupMediaCacheServer];
    [self _setupTableView];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJDYTableViewCell *cell=[SJDYTableViewCell cellWithTableView:tableView indexPath:indexPath];
    cell.indexPath = indexPath;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJDYTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *playbackURL = [SJMediaCacheServer.shared playbackURLWithURL:_list[indexPath.row].URL];
    [cell.player configureWithURL:playbackURL];
    __weak typeof(self) _self = self;
    cell.player.allowsPlayback = ^BOOL(id<SJDYDemoPlayer>  _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return NO;
        return [self.delegate canPerformPlayForListViewController:self];
    };
    if ( _curPlayer == nil ) {
        _curPlayer = cell.player;
    }
    if (self.list.count - indexPath.row <= 3 &&
        !self.isLoadingData) {
        self.isLoadingData = YES;
        [self loadDataWithShowLoading:NO];
    }
//    [_prePrefetchTask cancel];
//    [_nextPrefetchTask cancel];
//    _prePrefetchTask = [self _prefetchTaskWithIndex:indexPath.row - 1];
//    _nextPrefetchTask = [self _prefetchTaskWithIndex:indexPath.row + 1];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size.height;
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
    SJDYTableViewCell *target = nil;
    CGRect max = CGRectZero;
    for ( SJDYTableViewCell *cell in _tableView.visibleCells ) {
        CGRect intersection = [cell intersectionWithView:_tableView insets:UIEdgeInsetsZero];
        if ( intersection.size.height > max.size.height ) {
            target = cell;
            max = intersection;
        }
    }
    
    if ( target == nil )
        return;
    
    SJVideoModel *model = _list[target.indexPath.row];
    
    if (model.error) {
        [self showToastAlert];
    }
    
    id<SJDYDemoPlayer> cur = target.player;
    
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
    
    [self loadDataWithShowLoading:YES];
    
    [_tableView sj_exeHeaderRefreshingAnimated:NO]; // 执行头部刷新
}
#pragma Mark 本次修改主要为这里，在请求刷新处做无感处理（缓存处理为疯狂模式···）。
- (void)loadDataWithShowLoading:(BOOL)isShowLoading{
    //当有缓存未加载时，直接展示缓存数据
    if (self.isCacheData) {
        [self refreshView];
        return;
    }
    //      模拟请求网络数据
    __weak typeof(self) _self = self;
    //提前获取数据时，无须显示loading状态，直接请求数据。
    if (!isShowLoading) {
        // 模拟延迟
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.dataProvider playbackListWithPageNum:self.tableView.sj_pageNum pageSize:self.tableView.sj_pageSize completionHandler:^(NSArray<SJVideoModel *> * _Nullable list, NSError * _Nullable error) {
                __strong typeof(_self) self = _self;
                
                self.isLoadingData = NO;
                
                if ( !self ) return;
                if ( error ) {
                    // error
                    NSLog(@"%@", error);
                    return;
                }
                // 如果是请求首页的数据, 即下拉
                if ( self.tableView.sj_pageNum == self.tableView.sj_beginPageNum ) {
                    // 下拉刷新时, 清理播放数据
                    [self.curPlayer stop];
                    self.curPlayer = nil;
                    [self.list removeAllObjects];
                    [self.prefetchTaskArray removeAllObjects];
                }
                
                // 添加到播放列表中, 刷新列表
                [self.list addObjectsFromArray:list];
                NSIndexPath *idxP = [self.tableView indexPathsForVisibleRows].lastObject;
                
                for (int i = 0; i < idxP.row; i++) {
                    id<MCSPrefetchTask> task = self.prefetchTaskArray[i];
                    [task cancel];
                }
                
                if (idxP &&
                    self.tableView.sj_pageNum != self.tableView.sj_beginPageNum)
                    [self.prefetchTaskArray removeObjectsInRange:NSMakeRange(0, idxP.row - 1)];
                else
                    [self.prefetchTaskArray removeAllObjects];
                
                for (int i = 0; i < self.list.count; i++) {
                    [self.prefetchTaskArray addObject:[self _prefetchTaskWithIndex:i]];
                }
                
                //如果当前是最后一个，或者下拉刷新，直接刷新页面
                if (self.tableView.sj_pageNum == 1) {
                    [self refreshView];
                }else if (idxP && (self.list.count - 1 == idxP.row)) {
                    [self refreshView];
                    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + self.tableView.frame.size.height)];
                }else{
                    //否则缓存数据，待用户上拉是自动刷新并滑动到下一个视频，同时做到无感刷新
                    self.isCacheData = YES;
                }
            }];
        });
    }else{
        //只展示loading状态，只有下拉刷新时主动获取数据
        [_tableView sj_setupRefreshingWithPageSize:10 beginPageNum:1 refreshingBlock:^(__kindof UIScrollView * _Nonnull scrollView, NSInteger requestPageNum) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            
            if (requestPageNum == 1 ||
                !self.isLoadingData) {
                [self loadDataWithShowLoading:NO];
            }
        }];
    }
}
- (void)refreshView{
    self.isCacheData = NO;
    [self.tableView reloadData];
    [self.tableView sj_endRefreshingWithItemCount:self.list.count];
    [self _checkVisibleCells];
}
// 配置边播边缓存模块
- (void)_setupMediaCacheServer {
    // 开启控制台log
    SJMediaCacheServer.shared.enabledConsoleLog = NO;
    SJMediaCacheServer.shared.maxConcurrentPrefetchCount = 10;
    SJMediaCacheServer.shared.resolveAssetIdentifier = ^NSString * _Nonnull(NSURL * _Nonnull URL) {
        // 由于demo中同一个视频的URL后面的参数不一样, 为保证引用相同的缓存文件, 这里删除了URL后面的所有参数
        // 例如:
        //      - https://dh2.v.netease.com/2017/cg/fxtpty.mp4?id=0&key=value
        //      - https://dh2.v.netease.com/2017/cg/fxtpty.mp4?id=1
        //      这两个URL后面的参数不同, 但它们代表了同一个视频, 为保证引用相同的缓存文件, 这里需删除后面的所有参数, 保证返回的字符串一致
        return [URL.absoluteString stringByDeletingPathExtension];
    };
}

#pragma mark - 此处修改为请求数据回来直接批量缓存,因为现在改为无感刷新,所以每次可以请求少量数据进行缓存,并且添加了报错处理,但还需要改进

// 预加载指定位置的某个资源`1M`的内容  缓存失败回调处理。
- (nullable id<MCSPrefetchTask>)_prefetchTaskWithIndex:(NSInteger)index {
    if ( index < 0 || index >= _list.count )
        return nil;
    
//    id<MCSPrefetchTask> prefetch__Task = [SJMediaCacheServer.shared prefetchWithURL:_list[index].URL preloadSize:1 * 1024 * 1024];
    SJVideoModel *model = _list[index];
    id<MCSPrefetchTask> prefetch__Task = [SJMediaCacheServer.shared prefetchWithURL:model.URL preloadSize:1 * 1024 * 1024 progress:^(float progress) {
        
    } completed:^(NSError * _Nullable error) {
        if (error) {
            model.error = error;
            NSArray *array = [self.tableView visibleCells];
            NSInteger indexRow = -1;
            if (array.count > 0) {
                SJDYTableViewCell *cell = array.firstObject;
                indexRow = cell.indexPath.row;
            }
            if (indexRow == index) {
                [self showToastAlert];
            }
        }
    }];
    return prefetch__Task;
}
#pragma mark 报错提示,希望视频界面内部有调用方法
- (void)showToastAlert{
    UILabel *lab = [[UILabel alloc]init];
    [self.view addSubview:lab];
    lab.textColor = UIColor.whiteColor;
    lab.alpha = 0.9;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
    lab.text = @"视频加载失败";
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    [UIView animateWithDuration:2 animations:^{
        lab.alpha = 1;
    } completion:^(BOOL finished) {
        [lab removeFromSuperview];
    }];
}
#pragma mark 提前缓存数据对象
- (NSMutableArray *)prefetchTaskArray{
    if (!_prefetchTaskArray) {
        _prefetchTaskArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _prefetchTaskArray;
}
@end
