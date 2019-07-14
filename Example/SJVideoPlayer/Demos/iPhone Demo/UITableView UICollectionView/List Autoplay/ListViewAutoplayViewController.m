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
#import <SJUIKit/UIScrollView+SJRefreshAdd.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJBaseVideoPlayer/UIScrollView+ListViewAutoplaySJAdd.h>

#import "SJMeidaItemModel.h"
#import "SJRotationManager.h"

NS_ASSUME_NONNULL_BEGIN
static NSString *kDemoTableViewCell = @"DemoTableViewCell";

@interface ListViewAutoplayViewController ()<UITableViewDataSource, UITableViewDelegate, DemoTableViewCellDelegate, SJPlayerAutoplayDelegate>
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) NSMutableArray<DemoTableViewCellViewModel *> *models;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation ListViewAutoplayViewController

- (BOOL)shouldAutorotate {
    return NO;
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
    
    [self.tableView registerClass:[DemoTableViewCell class] forCellReuseIdentifier:kDemoTableViewCell];
    __weak typeof(self) _self = self;
    [self.tableView sj_setupRefreshingWithPageSize:20 beginPageNum:1 refreshingBlock:^(UITableView *tableView, NSInteger requestPageNum) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        // 网络请求之后返回的数据, 这里就不模拟请求了, 直接用数组创建这些数据了
        NSMutableArray<DemoTableViewCellViewModel *> *m = [NSMutableArray array];
        for ( int i = 0 ; i < tableView.sj_pageSize ; ++ i ) {
            [m addObject:[[DemoTableViewCellViewModel alloc] initWithModel:[SJMeidaItemModel testItem]]];
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
        
        _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:vm.URL playModel:[SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:vm.coverTag atIndexPath:indexPath tableView:self.tableView]];
        _player.URLAsset.title = vm.title;
    }
}
@end
NS_ASSUME_NONNULL_END



#import <SJRouter/SJRouter.h>
@interface ListViewAutoplayViewController (RouteHandler)<SJRouteHandler>

@end

@implementation ListViewAutoplayViewController (RouteHandler)

+ (NSString *)routePath {
    return @"demo/tableView/autoplay2";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}
@end
