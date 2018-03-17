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
#import "SJMediaDownloader.h"
#import "DownloadTableViewCell.h"
#import "SJVideo.h"
#import "SJVideo+DownloadAdd.h"

static NSString *const DownloadTableViewCellID = @"DownloadTableViewCell";

@interface DowloadViewController ()<UITableViewDelegate, UITableViewDataSource, DownloadTableViewCellDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray<SJVideo *> *videoList;

@end

@implementation DowloadViewController
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    [[SJMediaDownloader shared] startNotifier];
    
    [self prepareTestData];
    
    // Do any additional setup after loading the view.
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

- (void)prepareTestData {
    NSArray *videoList = [SJVideo testVideos];
    [videoList enumerateObjectsUsingBlock:^(SJVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SJMediaDownloader shared] async_requestMediaWithID:obj.mediaId completion:^(SJMediaDownloader * _Nonnull downloader, id<SJMediaEntity>  _Nullable media) {
            obj.downloadProgress = media.downloadProgress;
            obj.downloadStatus = media.downloadStatus;
            obj.filePath = media.filePath;
        }];
    }];
    
    __weak typeof(self) _self = self;
    [[SJMediaDownloader shared] async_exeBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoList = videoList;
            [self.tableView reloadData];
        });
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
    [[SJMediaDownloader shared] async_downloadWithID:cell.model.mediaId title:cell.model.title mediaURLStr:cell.model.playURLStr tmpEntity:nil];
}
- (void)clickedPauseBtnOnTabCell:(DownloadTableViewCell *)cell {
    [[SJMediaDownloader shared] async_pauseWithMediaID:cell.model.mediaId completion:nil];
}
- (void)clickedCancelBtnOnTabCell:(DownloadTableViewCell *)cell {
    [[SJMediaDownloader shared] async_deleteWithMediaID:cell.model.mediaId completion:nil];
}
@end
