//
//  ListViewAutoplayViewController.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/5/4.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "ListViewAutoplayViewController.h"
#import "DemoTableViewCellViewModel.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import <SJUIKit/UIScrollView+SJRefreshAdd.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *kDemoTableViewCell = @"DemoTableViewCell";

@interface ListViewAutoplayViewController ()<SJRouteHandler, UITableViewDataSource, UITableViewDelegate, DemoTableViewCellDelegate, SJPlayerAutoplayDelegate>
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) NSMutableArray<DemoTableViewCellViewModel *> *models;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation ListViewAutoplayViewController

+ (NSString *)routePath {
    return @"tableView/autoplay2";
}

+ (void)handleRequestWithParameters:(nullable SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(nullable SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _models = [NSMutableArray array];
    [self _configTableView];
    [self.tableView sj_exeHeaderRefreshing];
}

- (void)_configTableView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithPlayerSuperviewTag:DemoTableViewCellCoverTag autoplayDelegate:self];
    config.autoplayPosition = SJAutoplayPositionTop;
    [self.tableView sj_enableAutoplayWithConfig:config];
    
    NSArray<NSString *> *titles = @[@"一次邂逅, 遇见一生所爱", @"十五年前, 一见钟情", @"十五年后, 再次相遇"];
    NSArray<NSString *> *playURLs =
    @[@"https://xy2.v.netease.com/r/video/20190308/31cbdd25-3cc9-49d4-934c-8d29b54fc15b.mp4",
      @"https://xy2.v.netease.com/2018/0815/2b4c5207f8977c183897728dc6c77d58qt.mp4",
      @"https://xy2.v.netease.com/2018/0815/c4f8e15cf43e4404911c2e9d17d89d3fqt.mp4",
      @"https://xy2.v.netease.com/2018/0815/d08adab31cc9e6ce36111afc8a92c937qt.mp4",
      @"https://xy2.v.netease.com/2018/0815/bedf0f6f6573ca36c041932f4f601f06qt.mp4"];
    NSArray<NSString *> *covers = @[@"result_qq", @"result_wechat", @"result_weibo"];
    
    [self.tableView registerClass:[DemoTableViewCell class] forCellReuseIdentifier:kDemoTableViewCell];
    __weak typeof(self) _self = self;
    [self.tableView sj_setupRefreshingWithPageSize:20 beginPageNum:1 refreshingBlock:^(UITableView *tableView, NSInteger requestPageNum) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        // 网络请求之后返回的数据, 这里就不模拟请求了, 直接用数组创建这些数据了
        NSMutableArray<DemoTableViewCellViewModel *> *m = [NSMutableArray array];
        for ( int i = 0 ; i < tableView.sj_pageSize ; ++ i ) {
            DemoMediaModel *media = [DemoMediaModel new];
            media.title = titles[arc4random() % titles.count];
            media.playURL = playURLs[arc4random() % playURLs.count];
            media.coverURL = covers[arc4random() % covers.count];
            [m addObject:[[DemoTableViewCellViewModel alloc] initWithModel:media]];
        }
        
        if ( requestPageNum == tableView.sj_beginPageNum ) {
            [self.models removeAllObjects];
            [self.player.view removeFromSuperview];
            self.player.URLAsset = nil;
            self.tableView.sj_currentPlayingIndexPath = nil;
            [self.tableView sj_playNextVisibleAsset];
        }
        
        // 获取到数据之后, 结束mj刷新, 并且刷新tableView
        [self.models addObjectsFromArray:m];
        [self.tableView sj_endRefreshingWithItemCount:m.count];
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _models.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_models[indexPath.row] height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kDemoTableViewCell forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(DemoTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _models[indexPath.row];
    cell.delegate = self;
}

- (void)demoTableViewCell:(DemoTableViewCell *)cell clickedOnTheCover:(UIImageView *)cover {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath != nil ) {
        DemoTableViewCellViewModel *vm = _models[indexPath.row];
        if ( !_player ) {
            _player = [SJVideoPlayer player];
        }
        
        _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:vm.playURL] playModel:[SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:vm.coverTag atIndexPath:indexPath tableView:self.tableView]];
        _player.URLAsset.title = vm.title;
    }
}
@end
NS_ASSUME_NONNULL_END
