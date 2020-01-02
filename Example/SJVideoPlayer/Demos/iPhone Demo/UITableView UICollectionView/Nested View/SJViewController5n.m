//
//  SJViewController5n.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController5n.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJUIKit/SJUIKit.h>
#import <Masonry/Masonry.h>
#import "SJTableViewHeaderFooterView5n.h"
#import "SJMediasTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJViewController5n ()<UITableViewDataSource,  UITableViewDelegate, SJMediaItemsTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<SJMediasTableViewModel *> *sections;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation SJViewController5n

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray<SJMediasTableViewModel *> *m = [[NSMutableArray alloc] initWithCapacity:20];
        NSArray<NSString *> *testTitles = @[@"悲哀化身-内蒙专区", @"车迟国@最终幻想-剑侠风骨", @"老虎222-天竺国", @"今朝醉-云中殿", @"杀手阿七-五明宫", @"浅墨淋雨桥-剑胆琴心"];
        
        for ( int i = 0 ; i < 20 ; ++ i ) {
            NSString *title = testTitles[arc4random() % testTitles.count];
            [m addObject:[[SJMediasTableViewModel alloc] initWithTitle:title items:[SJMeidaItemModel testItems]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sections = m;
            [self.tableView reloadData];
        });
    });
}

- (void)mediaItemsTableViewCell:(SJMediaItemsTableViewCell *)tab_cell tappedOnTheCoverAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ( _player == nil ) {
        _player = [SJVideoPlayer player];
        _player.resumePlaybackWhenScrollAppeared = NO; //< 滚动出现时, 是否恢复播放, 此处设置为NO.
    }
    
    SJMediasTableViewModel *medias_vm = tab_cell.dataSource;
    SJExtendedMediaCollectionViewModel *p_vm = medias_vm.medias[indexPath.item];
    
    // 由于播放器将来要添加到被点击的cell上, 所以需要告诉播放器 相关视图的位置信息, 已防止复用的情况.
    //
    // 假设添加播放器后的视图层次如下, 我们忽略一些不必要的视图:
    //
    // UITableView -> UITableViewCell -> UICollectionView -> UICollectionViewCell -> PlayerSuperview -> PlayerView
    //
    // 我们根据这条链, 来创建 `SJPlayModel`
    //
    // 1. UITableView
    UITableView *tableView = _tableView;
    
    // 由于复用机制的存在, 对于某一个 Cell 通常我们是通过 indexPath 来获取它. 所以第二步是获取它的 indexPath
    //
    // 2. UITableViewCell 的 indexPath, 以及它上面的 UICollectionView 的 tag
    NSIndexPath *c_indexPath = [_tableView indexPathForCell:tab_cell];
    NSInteger c_tag = medias_vm.collectionViewTag;

    // 3. UICollectionViewCell 的 indexPath, 以及它上面的 PlayerSuperview 的 tag
    NSIndexPath *p_indexPath = indexPath;
    NSInteger p_tag = p_vm.coverTag;
    
    // 4. 创建 `SJPlayModel(视图模型)`
    SJPlayModel *cellModel = [SJPlayModel UICollectionViewNestedInUITableViewCellPlayModelWithPlayerSuperviewTag:p_tag atIndexPath:p_indexPath collectionViewTag:c_tag collectionViewAtIndexPath:c_indexPath tableView:tableView];
    
    // 5. 进行播放(创建资源)
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:p_vm.url playModel:cellModel];
}

#pragma mark -

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.width.offset(UIScreen.mainScreen.bounds.size.width);
    }];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [SJTableViewHeaderFooterView5n registerWithTableView:_tableView];
    [SJMediaItemsTableViewCell registerWithNib:[UINib nibWithNibName:@"SJMediaItemsTableViewCell" bundle:nil] tableView:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [SJTableViewHeaderFooterView5n reusableViewWithTableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(SJTableViewHeaderFooterView5n *)view forSection:(NSInteger)section {
    view.title = _sections[section].title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJMediaItemsTableViewCell cellWithTableView:tableView indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _sections[indexPath.section].height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJMediaItemsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _sections[indexPath.section];
    cell.delegate = self;
}

#pragma mark -

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

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end
NS_ASSUME_NONNULL_END

#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJViewController5n (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController5n (RouteHandler)

+ (NSString *)routePath {
    return @"demo/scrollView/nested";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[SJViewController5n new] animated:YES];
}

@end
