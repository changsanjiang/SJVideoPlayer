//
//  ViewControllerSJUITableViewHeaderFooterViewPlayModel.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/1/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "ViewControllerSJUITableViewHeaderFooterViewPlayModel.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>
#import "SJTableViewCell.h"
#import "SJVideoPlayer.h"
#import "SJTableViewHeaderFooterView.h"

@interface ViewControllerSJUITableViewHeaderFooterViewPlayModel ()<SJRouteHandler, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewControllerSJUITableViewHeaderFooterViewPlayModel

+ (NSString *)routePath {
    return @"tableView/headerFooterView/play";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = self.view.bounds.size.width * 9 / 16.0 + 8;
    [SJTableViewHeaderFooterView registerWithTableView:_tableView];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 99;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 180;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 300;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SJTableViewHeaderFooterView *headerView = [SJTableViewHeaderFooterView headerFooterViewWithTableView:tableView];
    __weak typeof(self) _self = self;
    headerView.view.clickedPlayButtonExeBlock = ^(SJPlayView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        SJPlayModel *playModel = [SJPlayModel UITableViewHeaderFooterViewPlayModelWithPlayerSuperviewTag:view.coverImageView.tag inSection:section isHeader:YES tableView:self.tableView];
        NSURL *URL = [NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"];
        
        SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:playModel];
        asset.title = @"Test Title";
        asset.alwaysShowTitle = YES;
        [self _playAsset:asset];
    };
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    SJTableViewHeaderFooterView *footerView = [SJTableViewHeaderFooterView headerFooterViewWithTableView:tableView];
    __weak typeof(self) _self = self;
    footerView.view.clickedPlayButtonExeBlock = ^(SJPlayView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        SJPlayModel *playModel = [SJPlayModel UITableViewHeaderFooterViewPlayModelWithPlayerSuperviewTag:view.coverImageView.tag inSection:section isHeader:NO tableView:self.tableView];
        NSURL *URL = [NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"];
        
        SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:playModel];
        asset.title = @"Test Title";
        asset.alwaysShowTitle = YES;
        [self _playAsset:asset];
    };
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJTableViewCell cellWithTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SJTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) _self = self;
    cell.view.clickedPlayButtonExeBlock = ^(SJPlayView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        SJPlayModel *playModel = [SJPlayModel UITableViewCellPlayModelWithPlayerSuperviewTag:view.coverImageView.tag atIndexPath:indexPath tableView:self.tableView];
        NSURL *URL = [NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"];
        
        SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:playModel];
        asset.title = @"Test Title";
        asset.alwaysShowTitle = YES;
        [self _playAsset:asset];
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

#pragma mark -

- (void)_playAsset:(SJVideoPlayerURLAsset *)asset {
    [self.player stopAndFadeOut];
    
    // create new player
    self.player = [SJVideoPlayer player];
    [asset.playModel.playerSuperview addSubview:self.player.view];
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.player.URLAsset = asset;
}
@end
