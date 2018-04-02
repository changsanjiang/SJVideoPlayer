//
//  TableViewHeaderIsCollectionViewDemoViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TableViewHeaderIsCollectionViewDemoViewController.h"
#import <SJUIFactory.h>
#import <Masonry.h>
#import "SJVideoListTableViewCell.h"
#import "SJVideoModel.h"
#import "SJVideoPlayer.h"
#import "SJVideoPlayerHelper.h"
#import <UIView+SJUIFactory.h>
#import "TableHeaderCollectionView.h"
#import "DemoPlayerViewController.h"
#import "YYTapActionLabel.h"

static NSString *const SJVideoListTableViewCellID = @"SJVideoListTableViewCell";

@interface TableViewHeaderIsCollectionViewDemoViewController ()<UITableViewDelegate, UITableViewDataSource, SJVideoListTableViewCellDelegate, NSAttributedStringTappedDelegate, SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) TableHeaderCollectionView *tableHeaderView;

@property (nonatomic, strong) NSArray<SJVideoModel *> *videosM;

@end

@implementation TableViewHeaderIsCollectionViewDemoViewController

@synthesize indicator = _indicator;
@synthesize tableView = _tableView;
@synthesize tableHeaderView = _tableHeaderView;

- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // setup views
    [self _videoListSetupViews];
    
    [self.indicator startAnimating];
    
    // prepare test data.
    self.tableView.alpha = 0.001;
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // some test data
        NSArray<SJVideoModel *> *videos = [SJVideoModel videoModelsWithTapActionDelegate:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.videosM = videos;
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
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self];
    return _videoPlayerHelper;
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

- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView {
    
    SJVideoPlayerURLAsset *asset =
    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]
                                         scrollView:self.tableView
                                          indexPath:[self.tableView indexPathForCell:cell]
                                       superviewTag:playerParentView.tag];
    asset.title = @"DIY心情转盘 #手工##手工制作#";
    asset.alwaysShowTitle = YES;
    
    [self.videoPlayerHelper playWithAsset:asset playerParentView:playerParentView];
}

#pragma mark -

- (void)_videoListSetupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.tableView.tableHeaderView = self.tableHeaderView;
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

- (TableHeaderCollectionView *)tableHeaderView {
    if ( _tableHeaderView ) return _tableHeaderView;
    _tableHeaderView = [SJUIViewFactory viewWithSubClass:[TableHeaderCollectionView class] backgroundColor:[UIColor lightGrayColor] frame:CGRectMake(0, 0, SJScreen_W(), [TableHeaderCollectionView height])];
    __weak typeof(self) _self = self;
    _tableHeaderView.clickedPlayBtnExeBlock = ^(TableHeaderCollectionView *view, UICollectionView *collectionView, NSIndexPath *indexPath, UIView *videoPlayerSuperView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        SJVideoPlayerURLAsset *asset =
        [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://vod.lanwuzhe.com/d57eed43d9a344e486b79ae505fb9044/18b1aeb398e04ffaa9de48f223dcf0ca-5287d2089db37e62345123a1be272f8b.mp4?video="]
                                              beginTime:0
                            collectionViewOfTableHeader:collectionView
                                collectionCellIndexPath:indexPath
                                     playerSuperViewTag:videoPlayerSuperView.tag
                                          rootTableView:self.tableView];
        
        asset.title = @"DIY心情转盘 #手工##手工制作#";
        [self.videoPlayerHelper playWithAsset:asset playerParentView:videoPlayerSuperView];
    };
    return _tableHeaderView;
}

- (UITableView *)tableView {
    if ( _tableView ) return _tableView;
    _tableView = [SJUITableViewFactory tableViewWithStyle:UITableViewStylePlain backgroundColor:[UIColor whiteColor] separatorStyle:UITableViewCellSeparatorStyleNone showsVerticalScrollIndicator:YES delegate:self dataSource:self];
    [_tableView registerClass:NSClassFromString(SJVideoListTableViewCellID) forCellReuseIdentifier:SJVideoListTableViewCellID];
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videosM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoListTableViewCell heightWithContentHeight:_videosM[indexPath.row].videoContentLayout.textBoundingSize.height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJVideoListTableViewCell * cell = (SJVideoListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SJVideoListTableViewCellID forIndexPath:indexPath];
    cell.model = _videosM[indexPath.row];
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

