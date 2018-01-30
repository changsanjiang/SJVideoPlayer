//
//  NestedTableViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "NestedTableViewController.h"
#import "SJVideoPlayer.h"
#import "NestedTableViewCell.h"
#import "PlayerCollectionViewCell.h"
#import <Masonry.h>
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>


static NSString *const NestedTableViewCellID = @"NestedTableViewCell";

@interface NestedTableViewController ()<NestedTableViewCellDelegate>

@property (nonatomic, strong, readwrite) SJVideoPlayer *videoPlayer;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL controlViewDisplayed;

@end

@implementation NestedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Nested scrollView(嵌套view)";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:NSClassFromString(NestedTableViewCellID) forCellReuseIdentifier:NestedTableViewCellID];
    self.tableView.rowHeight = [NestedTableViewCell height];
    
    
    // begin pop
    __weak typeof(self) _self = self;
    self.sj_viewWillBeginDragging = ^(__kindof UIViewController *vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.disableRotation = YES;
    };
    
    self.sj_viewDidEndDragging = ^(__kindof UIViewController *vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.disableRotation = NO;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NestedTableViewCell *cell = (NestedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NestedTableViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - TabCell Delegate

- (void)clickedPlayWithNestedTabCell:(NestedTableViewCell *)tabCell
                    playerParentView:(UIView *)playerParentView
                           indexPath:(NSIndexPath *)indexPath
                      collectionView:(UICollectionView *)collectionView {
    
    // old player fade out
    [_videoPlayer stopAndFadeOut];
    
    // create new player
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.view.alpha = 0.001;
    [playerParentView addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    
    // fade in
    [UIView animateWithDuration:0.5 animations:^{
        _videoPlayer.view.alpha = 1;
    }];

    // create asset
    NSURL *playURL = [NSURL URLWithString:@"http://blurdancer-video.oss-cn-shanghai.aliyuncs.com/usertrend/120718-1515947072.mp4"];
    
    NSIndexPath *embeddedScrollViewIndexPath = [self.tableView indexPathForCell:tabCell];
    UIView *embeddedScrollView = collectionView;
    _videoPlayer.URLAsset =
    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:playURL
                                              indexPath:indexPath
                                           superviewTag:playerParentView.tag
                                    scrollViewIndexPath:embeddedScrollViewIndexPath
                                          scrollViewTag:embeddedScrollView.tag
                                         rootScrollView:self.tableView];
    
    // setting player
    __weak typeof(self) _self = self;
    _videoPlayer.willRotateScreen = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    // Call when the control view is hidden or displayed.
    _videoPlayer.controlViewDisplayStatus = ^(SJVideoPlayer * _Nonnull player, BOOL displayed) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setNeedsStatusBarAppearanceUpdate];
    };
}

#pragma mark -

- (BOOL)prefersStatusBarHidden {
    // 全屏播放时, 使状态栏根据控制层显示或隐藏
    if ( _videoPlayer.isFullScreen ) return !_videoPlayer.controlViewDisplayed;
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 全屏播放时, 使状态栏变成白色
    if ( _videoPlayer.isFullScreen ) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}
@end

