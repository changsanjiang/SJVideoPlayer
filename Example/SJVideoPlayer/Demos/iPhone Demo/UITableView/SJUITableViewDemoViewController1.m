//
//  SJUITableViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUITableViewDemoViewController1.h"
#import <Masonry/Masonry.h>
#import "SJVideoCellViewModel.h"

@interface SJUITableViewDemoViewController1 ()<SJVideoTableViewCellDelegate>
@property (nonatomic, strong, readonly) NSMutableArray<SJVideoCellViewModel *> *models;
@end

@implementation SJUITableViewDemoViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)coverItemWasTapped:(SJVideoTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SJVideoCellViewModel *vm = _models[indexPath.row];
    
    if ( !_player ) {
        _player = [SJVideoPlayer player];
    }
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:vm.url playModel:[SJPlayModel playModelWithTableView:_tableView indexPath:indexPath superviewSelector:NSSelectorFromString(@"coverImageView")]];
    _player.URLAsset.title = vm.mediaTitle.string;
}

#pragma mark -

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
        
    [SJVideoTableViewCell registerWithTableView:_tableView];
 
    // 创建测试数据
    _models = NSMutableArray.array;
    __auto_type items = [SJVideoModel testItemsWithCount:3];
    for ( SJVideoModel *item in items ) {
        [_models addObject:[SJVideoCellViewModel.alloc initWithItem:item]];
    }
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _models.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_models[indexPath.row] height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoTableViewCell cellWithTableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJVideoTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _models[indexPath.row];
    cell.delegate = self;
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

@end
