//
//  LightweightViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "LightweightViewController.h"
#import <SJUIFactory.h>
#import <Masonry.h>
#import "LightweightTableViewCell.h"
#import "SJVideoModel.h"
#import "SJVideoPlayer.h"
#import "SJVideoPlayerHelper.h"
#import <UIView+SJUIFactory.h>
#import "DemoPlayerViewController.h"
#import "YYTapActionLabel.h"

static NSString *const LightweightTableViewCellID = @"LightweightTableViewCell";

@interface LightweightViewController ()<UITableViewDelegate, UITableViewDataSource, LightweightTableViewCellDelegate, NSAttributedStringTappedDelegate, SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *playedIndexPath;
@property (nonatomic, strong) NSArray<SJVideoModel *> *videos;

@end

@implementation LightweightViewController

@synthesize indicator = _indicator;
@synthesize tableView = _tableView;

- (void)dealloc {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup views
    [self _videoListSetupViews];
    
    [self.indicator startAnimating];
    // prepare test data.
    self.tableView.alpha = 0.001;
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // some test data
        NSArray<SJVideoModel *> *videos = [SJVideoModel lightweightVideoModelsWithTapActionDelegate:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.videos = videos;
            [self.tableView reloadData];
            [self.indicator stopAnimating];
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.alpha = 1;
            }];
        });
    });
    
    // Do any additional setup after loading the view.
}

// please lazy load
@synthesize videoPlayerHelper = _videoPlayerHelper;
- (SJVideoPlayerHelper *)videoPlayerHelper {
    if ( _videoPlayerHelper ) return _videoPlayerHelper;
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self playerType:SJVideoPlayerType_Lightweight];
    return _videoPlayerHelper;
}

- (BOOL)needConvertAsset {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.videoPlayerHelper.vc_viewDidAppearExeBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.videoPlayerHelper.vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.videoPlayerHelper.vc_viewDidDisappearExeBlock();
}

- (BOOL)prefersStatusBarHidden {
    return self.videoPlayerHelper.vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.videoPlayerHelper.vc_preferredStatusBarStyleExeBlock();
}

- (void)clickedPlayOnTabCell:(LightweightTableViewCell *)cell playerParentView:(UIView *)playerParentView {
    self.playedIndexPath = [self.tableView indexPathForCell:cell];
    SJVideoPlayerURLAsset *asset =
    //    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]
    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"]
                                         scrollView:self.tableView
                                          indexPath:[self.tableView indexPathForCell:cell]
                                       superviewTag:playerParentView.tag];
    asset.title = cell.model.title;
    asset.alwaysShowTitle = YES;
    
    [self.videoPlayerHelper playWithAsset:asset playerParentView:playerParentView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoPlayerURLAsset *asset = nil;
    if ( [self.playedIndexPath isEqual:indexPath] ) {
        asset = self.videoPlayerHelper.asset;
    }
    DemoPlayerViewController *vc = [[DemoPlayerViewController alloc] initWithVideo:self.videos[indexPath.row] asset:asset];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -

- (void)_videoListSetupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIActivityIndicatorView *)indicator {
    if ( _indicator ) return _indicator;
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.csj_size = CGSizeMake(80, 80);
    _indicator.center = self.view.center;
    _indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
    _indicator.clipsToBounds = YES;
    _indicator.layer.cornerRadius = 6;
    [self.view addSubview:_indicator];
    return _indicator;
}

- (UITableView *)tableView {
    if ( _tableView ) return _tableView;
    _tableView = [SJUITableViewFactory tableViewWithStyle:UITableViewStylePlain backgroundColor:[UIColor whiteColor] separatorStyle:UITableViewCellSeparatorStyleNone showsVerticalScrollIndicator:YES delegate:self dataSource:self];
    [_tableView registerClass:NSClassFromString(LightweightTableViewCellID) forCellReuseIdentifier:LightweightTableViewCellID];
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LightweightTableViewCell heightWithContentHeight:_videos[indexPath.row].videoContentLayout.textBoundingSize.height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LightweightTableViewCell * cell = (LightweightTableViewCell *)[tableView dequeueReusableCellWithIdentifier:LightweightTableViewCellID forIndexPath:indexPath];
    cell.model = _videos[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - other
- (void)attributedString:(NSAttributedString *)attrStr tappedStr:(NSAttributedString *)tappedStr {
    UIViewController *vc = [[self class] new];
    vc.title = tappedStr.string;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tappedOtherPlacesOfAttributedString:(NSAttributedString *)attrStr {
    SJVideoModel *model = attrStr.object;
    SJVideoPlayerURLAsset *asset = nil;
    if ( [self.videoPlayerHelper.currentPlayURL.absoluteString isEqualToString:model.playURLStr] ) {
        asset = self.videoPlayerHelper.asset;
    }
    DemoPlayerViewController *vc = [[DemoPlayerViewController alloc] initWithVideo:model asset:asset];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

