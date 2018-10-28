//
//  ViewControllerSJUICollectionViewNestedInUITableViewHeaderViewPlayModel.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerSJUICollectionViewNestedInUITableViewHeaderViewPlayModel.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import "SJTableViewCell.h"
#import "SJVideoPlayer.h"
#import "SJHasCollectionView.h"

@interface ViewControllerSJUICollectionViewNestedInUITableViewHeaderViewPlayModel ()<SJRouteHandler, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewControllerSJUICollectionViewNestedInUITableViewHeaderViewPlayModel

+ (NSString *)routePath {
    return @"tableView/tableHeaderView/collectionView/cell/play";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = self.view.bounds.size.width * 9 / 16.0 + 8;
    
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    
    SJHasCollectionView *tableHeaderView = [[SJHasCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    __weak typeof(self) _self = self;
    tableHeaderView.clickedPlayButtonExeBlock = ^(SJHasCollectionView * _Nonnull tableHeaderView, SJPlayView * _Nonnull view, NSIndexPath * _Nonnull indexPath) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        
        [self.player stopAndFadeOut];
        
        // create new player
        self.player = [SJVideoPlayer player];
#ifdef SJMAC
        self.player.disablePromptWhenNetworkStatusChanges = YES;
#endif
        [view.coverImageView addSubview:self.player.view];
        [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"] playModel:[SJPlayModel UICollectionViewNestedInUITableViewHeaderViewPlayModelWithPlayerSuperviewTag:view.coverImageView.tag atIndexPath:indexPath collectionView:tableHeaderView.collectionView tableView:self.tableView]];
        self.player.URLAsset.title = @"Test Title";
        self.player.URLAsset.alwaysShowTitle = YES;
    };
    _tableView.tableHeaderView = tableHeaderView;
    
    
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJTableViewCell cellWithTableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) _self = self;
    cell.view.clickedPlayButtonExeBlock = ^(SJPlayView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.player stopAndFadeOut];
        
        // create new player
        self.player = [SJVideoPlayer player];
#ifdef SJMAC
        self.player.disablePromptWhenNetworkStatusChanges = YES;
#endif
        [view.coverImageView addSubview:self.player.view];
        [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"] playModel:[SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:view.coverImageView.tag atIndexPath:indexPath tableView:self.tableView]];
        self.player.URLAsset.title = @"Test Title";
        self.player.URLAsset.alwaysShowTitle = YES;
    };
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
