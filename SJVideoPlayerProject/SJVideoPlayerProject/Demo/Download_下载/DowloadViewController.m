//
//  DowloadViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "DowloadViewController.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry/Masonry.h>
#import <SJMediaDownloader.h>
#import "DownloadTableViewCell.h"
#import "SJVideo.h"
#import "SJVideo+DownloadAdd.h"
#import "SJVideoPlayer.h"
#import "SJVideoPlayerHelper.h"

static NSString *const DownloadTableViewCellID = @"DownloadTableViewCell";

@interface DowloadViewController ()<UITableViewDelegate, UITableViewDataSource, DownloadTableViewCellDelegate, SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray<SJVideo *> *videoList;
@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;

@end

@implementation DowloadViewController
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    [[SJMediaDownloader shared] startNotifier];
    
    [self prepareTestData];
    
    [self _installDownloaderNotifications];
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [[SJMediaDownloader shared] stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (void)prepareTestData {
    NSArray *videoList = [SJVideo testVideos];
    [videoList enumerateObjectsUsingBlock:^(SJVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addDownloadObserver];
    }];
    
    __weak typeof(self) _self = self;
    [[SJMediaDownloader shared] async_exeBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.videoList = videoList;
            [self.tableView reloadData];
        });
    }];
}

- (void)_installDownloaderNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDownloadStatusChanged:) name:SJMediaDownloadStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDownloadProgress:) name:SJMediaDownloadProgressNotification object:nil];
}
- (void)mediaDownloadStatusChanged:(NSNotification *)notifi {
    id<SJMediaEntity> entity = notifi.object;
    [self _updateLayoutWithEntity:entity];
}

- (void)mediaDownloadProgress:(NSNotification *)notifi {
    id<SJMediaEntity> entity = notifi.object;
    [self _updateLayoutWithEntity:entity];
}

- (void)_updateLayoutWithEntity:(id<SJMediaEntity>)entity {
    [_videoList enumerateObjectsUsingBlock:^(SJVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj.mediaId != entity.mediaId ) return;
        *stop = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            DownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            [cell update];
        });
    }];
}

#pragma mark - video player helper
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

- (void)tabCell:(DownloadTableViewCell *)cell clickedPlayBtnAtCoverImageView:(UIImageView *)coverImageView {
    NSURL *URL = nil;
    if ( cell.model.entity.filePath ) {
        URL = [NSURL fileURLWithPath:cell.model.entity.filePath];
    }
    else {
        URL = [NSURL URLWithString:cell.model.playURLStr];
    }
    
    SJVideoPlayerURLAsset *asset =
    [[SJVideoPlayerURLAsset alloc] initWithAssetURL:URL
                                         scrollView:self.tableView
                                          indexPath:[self.tableView indexPathForCell:cell]
                                       superviewTag:coverImageView.tag];
    asset.title = cell.model.title;
    asset.alwaysShowTitle = YES;

    [self.videoPlayerHelper playWithAsset:asset playerParentView:coverImageView];
}
#pragma mark -
- (void)_setupViews {
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleDone target:self action:@selector(clear)];
}

- (void)clear {
    [_videoList enumerateObjectsUsingBlock:^(SJVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SJMediaDownloader shared] async_deleteWithMediaID:obj.mediaId completion:nil];
    }];
}

- (UITableView *)tableView {
    if ( _tableView ) return _tableView;
    _tableView = [SJUITableViewFactory tableViewWithStyle:UITableViewStylePlain backgroundColor:[UIColor whiteColor] separatorStyle:UITableViewCellSeparatorStyleNone showsVerticalScrollIndicator:YES delegate:self dataSource:self];
    [_tableView registerClass:NSClassFromString(DownloadTableViewCellID) forCellReuseIdentifier:DownloadTableViewCellID];
    _tableView.estimatedRowHeight = 200;
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( _videoList ) return _videoList.count;
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = (DownloadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:DownloadTableViewCellID forIndexPath:indexPath];
    cell.model = _videoList[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (void)clickedDownloadBtnOnTabCell:(DownloadTableViewCell *)cell {
    [[SJMediaDownloader shared] async_downloadWithID:cell.model.mediaId title:cell.model.title mediaURLStr:cell.model.playURLStr];
}
- (void)clickedPauseBtnOnTabCell:(DownloadTableViewCell *)cell {
    [[SJMediaDownloader shared] async_pauseWithMediaID:cell.model.mediaId completion:nil];
}
- (void)clickedCancelBtnOnTabCell:(DownloadTableViewCell *)cell {
    [[SJMediaDownloader shared] async_deleteWithMediaID:cell.model.mediaId completion:nil];
}
@end
